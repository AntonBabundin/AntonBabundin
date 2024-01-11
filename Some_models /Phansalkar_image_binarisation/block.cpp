#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <map>
#include <string>
#include <iostream>
#include <cmath>

cv::Mat phansalkar_threshold_square(cv::Mat &img, int ksize=11, double k=0.25, double r=0.5, int p = 2, int q = 10){
    cv::Mat mean;
    cv::Mat meanSquare;
    cv::Mat treshold;
    img /= 256;
    img.convertTo(img, CV_32F);
    img /= 256.;

    std::vector<int> lut_exp;
    std::vector<int> lut_sqrt;

    auto kernel = static_cast<cv::Mat>(cv::Mat::ones(ksize, ksize, CV_32F));
    kernel /= cv::sum(kernel);
    // mean
    cv::filter2D(img, mean, -1, kernel);
    std::cout << mean.type() << "\n";
    // deviation
    auto output_img = img.mul(img);
    cv::filter2D(output_img, meanSquare, -1, kernel);
    cv::Mat variance = cv::Mat(meanSquare.rows, meanSquare.cols, CV_32F);
    

    for (auto i = 0 ; i < meanSquare.rows; ++i)
    {
        for (auto j = 0 ; j < meanSquare.cols; ++j)
        {
            variance.at<float_t>(i,j) = std::abs(meanSquare.at<float_t>(i,j) - mean.at<float_t>(i,j)*mean.at<float_t>(i,j));
        }
    }
    for (auto i = 0; i < 256; ++i)
    {
        int tmp = static_cast<int>((std::exp(-q*i/256)*p)*16384)/16384;
        lut_exp.push_back(tmp);
    }

    for (auto i = 0; i < 256; ++i)
    {
        int tmp = static_cast<int>((((std::sqrt(i/256)/r)-1)*k)*16384)/16384;
        lut_sqrt.push_back(tmp);
    }
    

    auto lut_exp_img = static_cast<cv::Mat>(cv::Mat::zeros(img.rows, img.cols, CV_16UC1));
    auto lut_sqrt_img = static_cast<cv::Mat>(cv::Mat::zeros(img.rows, img.cols, CV_16UC1));

    for (auto i = 0 ; i < img.rows; ++i)
    {
        for (auto j = 0 ; j < img.cols; ++j)
        {
            int addr0 = static_cast<uint16_t>(mean.at<float>(i,j)*256);
            int addr1 = static_cast<uint16_t>(variance.at<float>(i,j)*256);
            lut_exp_img.at<uint16_t>(i,j) = lut_exp[addr0];
            variance.at<uint16_t>(i,j) = lut_sqrt[addr1];
        }
    }
    
    cv::add(1+lut_exp_img, lut_sqrt_img, treshold);

    treshold.convertTo(treshold, CV_32F);
    treshold = treshold.mul(mean);
    cv::Mat mask = img > treshold;
    mask.convertTo(mask, CV_32F);
    img = img.mul(mask);
    img.forEach<float>([](float &point, const int * position) -> void {
        if (point>0){
            point=65535;
        }
    });
    return img;
}

model::NodeStream<model::sv::Target> detect_action(cv::Mat &img, std::string name){
    model::NodeStream<model::sv::Target> targets;
    model::sv::Target target;

    int H = img.rows;
    int W = img.cols;
    //resize
    cv::resize(img, img, cv::Size(H/4,W/4));    
    //Mean
    cv::Mat kernel = cv::Mat::ones(5, 5, CV_32F)/25;

    cv::filter2D(img, img, -1, kernel);
    //threshold
    img = phansalkar_threshold_square(img);
    cv::imwrite(name+"_localthreshold.png", img);
    //erode & dilate
    kernel = cv::Mat::ones(5, 5, CV_16UC1);
    cv::dilate(img, img, kernel);

    kernel = cv::Mat::ones(3, 3, CV_16UC1);
    cv::erode(img, img, kernel);

    cv::imwrite(name+"_close.png", img);
    img = 65535 - img;
    //Threshold
    img.forEach<uint16_t>([](uint16_t &point, const int * position) -> void {
        if (point>0){
            point=1;
        }
    });

    std::vector<tmp_val> prev_line;
    std::vector<tmp_val> result;
    std::vector<tmp_val> cur_line;
    for (int y = 0; y < img.rows; ++y)
    {
        cur_line = runDetect(img, y, img.cols, false);
        std::cout << y << "\n";
        prev_line = processLine(prev_line, cur_line, result, false);
    }

    std::cout << "Size " << result.size() << "\n";
    while (!result.empty())
    {   
        
        tmp_val tmp_prev = result[0];
        result.erase(result.begin());

        target.x = tmp_prev.xmin*4;
        target.y = tmp_prev.ymin*4;
        target.xend = tmp_prev.xmax*4;
        target.yend = tmp_prev.ystart*4;
        std::cout << target.x << " " << target.y << " " << target.xend << " " << target.yend << "\n";
        targets.push_back(target);
    }
    return targets;
}

namespace model {

class DetectorBlock final : public Block
{
    unsigned width_;
    unsigned height_;

    public:
        explicit DetectorBlock(const Context& context) :
            width_(context.query<int>("/Artec/Model/image/width")),
            height_(context.query<int>("/Artec/Model/image/height"))
        {}

        Channel process(Channel&& channel, ProcessInfo& info) override
        {   
            auto image_far =
                cv::Mat(height_, width_, CV_16UC1, channel["image_far"].data());
            auto image_middle =
                cv::Mat(height_, width_, CV_16UC1, channel["image_middle"].data());
            auto image_close =
                cv::Mat(height_, width_, CV_16UC1, channel["image_close"].data());

            channel["targets_far"] = detect_action(image_far, "far");
            channel["targets_middle"] = detect_action(image_middle, "middle");
            channel["targets_close"] = detect_action(image_close, "close");

            return std::move(channel);
        }
};

}  // namespace model

extern "C" model::Block* initialize(const model::Context& context)
{
    return new model::DetectorBlock(context);
}

extern "C" void uninitialize(model::Block* block)
{
    delete block;
}