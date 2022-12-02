//
//  DynamicLinkBuilder.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/19.
//

import FirebaseDynamicLinks

class DynamicLinkBuilder {
    
    static func createDynamicLink(diaryUUID: String, completion: @escaping (String) -> Void) {
        let dynamicLinksDomainURIPrefix = "https://tdaa.page.link"
        var shortenURL = dynamicLinksDomainURIPrefix
        
        guard let link = URL(string: "\(dynamicLinksDomainURIPrefix)/\(diaryUUID)") else { return }
        guard let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix) else { return }
        
        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.San.MacC-GoldenRatio")
        linkBuilder.iOSParameters?.appStoreID = "6443840961"
        
        linkBuilder.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkBuilder.socialMetaTagParameters?.title = "LzInvitationTitle".localized
        linkBuilder.socialMetaTagParameters?.descriptionText = "LzInvitationMessage".localized
        linkBuilder.socialMetaTagParameters?.imageURL = URL(string: "https://github.com/Dorodong96/iOS-StudyProjects/blob/main/FastCampus/Challange%20Images/banner.png?raw=true")
        
        guard let longDynamicLink = linkBuilder.url else { return }
        
        DynamicLinkComponents.shortenURL(longDynamicLink, options: nil) { url, _, _ in
            guard let url = url else { return }
            shortenURL = url.absoluteString
            completion(shortenURL)
        }

    }
}
