//
//  GKWYWidgetView.swift
//  GKWYWidgetExtension
//
//  Created by gaokun on 2020/11/11.
//  Copyright © 2020 gaokun. All rights reserved.
//

import SwiftUI
import WidgetKit

struct GKWYSmallView: View {
    let data: GKWYData
    
    var body: some View {
        GeometryReader { geo in
            GKWYItemView(data: data)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct GKWYMediumView: View {
    let list: [GKWYData]
    
    var body: some View {
        GeometryReader { geo in
            let itemWH = geo.size.height - 20
            let data = list[0]
            
            ZStack() {
                HStack(alignment: .center, spacing: 10) {
                    GKWYItemView(data: data)
                        .frame(width: itemWH, height: itemWH)
                    VStack(spacing: 10) {
                        GKWYMenuView(data: list[1])
                        GKWYMenuView(data: list[2])
                    }
                }
            }
            .padding(12)
            .background(GKWYColorView(image: data.bgImage))
            .cornerRadius(15)
        }
    }
}

struct GKWYLargeView: View {
    let list: [GKWYData]
    
    var body: some View {
        GeometryReader { geo in
            let data = list[0]
            
            VStack(alignment: .leading, spacing: 0) {
                ZStack() {
                    Image("cm2_clock_logo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                        .position(x: geo.size.width - (20/2) - 10, y: (20/2) + 10)
                        .ignoresSafeArea(.all)
                    
                    HStack(alignment: .center) {
                        Image(uiImage: data.bgImage!).resizable().frame(width: 120, height: 120).cornerRadius(10)
                            .position(x: 80, y: geo.size.height / 4)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack() {
                                Image("cm4_disc_type_list")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 20, height: 20)
                                Text(data.title).font(.system(size: 18)).foregroundColor(.white).fontWeight(.medium).lineLimit(1)
                            }
                            Text(data.desc).font(.system(size: 16)).foregroundColor(.white)
                        }.position(x: 60, y: geo.size.height / 4)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height / 2.0)
                .background(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.15)]), startPoint: .leading, endPoint: .trailing))
                
                ZStack(alignment: .center) {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            GKWYMenuView(data: list[1])
                            GKWYMenuView(data: list[2])
                        }
                        HStack(spacing: 8) {
                            GKWYMenuView(data: list[3])
                            GKWYMenuView(data: list[4])
                        }
                    }
                }
                .padding(13)
                .frame(width: geo.size.width, height: geo.size.height / 2.0)
                .background(Color.black.opacity(0.1))
            }
//            .padding(EdgeInsets(top: 12, leading: 6, bottom: 6, trailing: 6))
            .background(GKWYColorView(image: data.bgImage))
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct GKWYItemView: View {
    let data: GKWYData
    
    var body: some View {
        Link(destination: URL(string: (typePrefix + data.type))!) {
            ZStack(alignment: .bottomLeading) {
                GKWYWidgetSmallBackgroundView(bgImage: data.bgImage)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 4) {
                        Image("cm4_disc_type_list")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 18, height: 18)
                        
                        Text(data.title)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    
                    Text(data.desc)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .fontWeight(.regular)
                        .lineLimit(1)
                        .frame(height: 18)
                }
                .padding(.init(top: 0, leading: 12, bottom: 30, trailing: 12))
            }.cornerRadius(10)
        }
    }
}

struct GKWYMenuView: View {
    let data: GKWYData
    
    var body: some View {
        let imgWH = UIScreen.main.bounds.size.width / 750.0 * 36.0
        Link(destination: URL(string: (typePrefix + data.type))!) {
            ZStack(alignment: .leading) {
                Image("cm6_widget_button_background").resizable().cornerRadius(10).opacity(0)
                HStack(alignment: .center, spacing: 10) {
                    Image(data.icon).resizable().frame(width: imgWH, height: imgWH)
                    Text(data.title).font(.system(size: 15)).foregroundColor(.white).fontWeight(.medium)
                }.padding(.leading)
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.15)]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(10)
        }
    }
}

struct GKWYColorView: View {
    let image: UIImage?
    
    var body: some View {
        ZStack() {
            Color((image?.mostColor())!)
            Color.black.opacity(0.25)
        }
    }
}

struct GKWYWidgetSmallBackgroundView: View {
    let bgImage: UIImage?
    
    // 底部遮罩的占比为整体高度的40%
    var containerRatio: CGFloat = 1.0
    
    // 从上到下的渐变颜色
    let gradientTopColor = Color(hex: "0x000000", alpha: 0)
    let gradientBottomColor = Color(hex: "0x000000", alpha: 0.45)

    // 遮罩视图 简单封装 使代码更为直观
    func gradientView() -> LinearGradient {
        return LinearGradient(gradient: Gradient(colors: [gradientTopColor, gradientBottomColor]), startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        // 背景图片
        let backgroundImage: Image = GKWYImage.image(uiImage: bgImage)
        
        // 使用 GeometryReader 获取小组件的大小
        GeometryReader { geo in
            // 使用ZStack 叠放logo图标和底部遮罩
            ZStack {
                // 构建logo图标，使用frame确定图标大小，使用position定位图标的位置
                Image("cm2_clock_logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .position(x: geo.size.width - (20/2) - 10, y: (20/2) + 10)
                    .ignoresSafeArea(.all)

                // 构建遮罩视图，使用frame确定遮罩大小，使用position定位遮罩位置
                gradientView()
                    .frame(width: geo.size.width, height: geo.size.height * CGFloat(containerRatio))
                    .position(x: geo.size.width / 2.0, y: geo.size.height * (1 - CGFloat(containerRatio / 2.0)))
            }
            .frame(width: geo.size.width, height: geo.size.height)
            // 添加上覆盖底部的背景图片
            .background(backgroundImage.resizable().scaledToFill())
        }
    }
}

struct GKWYImage {
    static func image(uiImage: UIImage?) -> Image {
        if uiImage != nil {
            return Image(uiImage: uiImage!)
        }else {
            return Image("background")
        }
    }
}

struct GKWYWidgetView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct GKWYWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        let list = GKWYData.getList()
        
        // 小号组件预览
        GKWYSmallView(data: list.first!).previewContext(WidgetPreviewContext(family: .systemSmall))
        
        // 中号组件预览
        GKWYMediumView(list: list).previewContext(WidgetPreviewContext(family: .systemMedium))
        
        // 大号组件预览
        GKWYLargeView(list: list).previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

extension UIImage {
    func image(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        color.setFill()
        let bounds = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension UIImage {
    func mostColor() -> UIColor {
        
        
        let width: CGFloat = 90
        let height: CGFloat = 105
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        var pixelData: [UInt8] = [0, 0, 0, 0]
        
        pixelData.withUnsafeMutableBytes { pointer in
            if let context = CGContext(data: pointer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue), let cgImage = self.cgImage {
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        }
        
        let red = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha = CGFloat(pixelData[3]) / CGFloat(255.0)
        
        if #available(iOS 10.0, *) {
            return UIColor(displayP3Red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    /**
     根据坐标获取图片中的像素颜色值
     */
    subscript (x: Int, y: Int) -> UIColor? {

        if x < 0 || x > Int(size.width) || y < 0 || y > Int(size.height) {
            return nil
        }

        let provider = self.cgImage!.dataProvider
        let providerData = provider!.data
        let data = CFDataGetBytePtr(providerData)

        let numberOfComponents = 4
        let pixelData = ((Int(size.width) * y) + x) * numberOfComponents

        let r = CGFloat(data![pixelData]) / 255.0
        let g = CGFloat(data![pixelData + 1]) / 255.0
        let b = CGFloat(data![pixelData + 2]) / 255.0
        let a = CGFloat(data![pixelData + 3]) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension Color {
    // 十六进制颜色字符串转Color
    init(hex: String, alpha: Double = 1) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        let scanner = Scanner(string: hexString)
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        let components = (
            R: Double((color >> 16) & 0xff) / 255,
            G: Double((color >> 08) & 0xff) / 255,
            B: Double((color >> 00) & 0xff) / 255
        )
        self.init(.sRGB, red: components.R, green: components.G, blue: components.B, opacity: alpha)
    }
}
