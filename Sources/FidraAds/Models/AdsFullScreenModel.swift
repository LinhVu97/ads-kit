//
//  AdsFullScreenModel.swift
//  FidraCore
//
//  Created by HoaTD on 4/3/25.
//

public class AdsFullScreenModel {
    public enum AdStatusEnum {
        case notLoaded    // Chưa load hoặc đã đóng
        case loading      // Đang load
        case loaded      // Đã load thành công
        case failed      // Load thất bại
        case showing     // Đang hiển thị
    }
}
