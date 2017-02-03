//
//  RChatDataSource.swift
//  RChat
//
//  Created by Max Alexander on 1/10/17.
//  Copyright © 2017 Max Alexander. All rights reserved.
//

import Foundation
import Chatto
import RealmSwift

class RChatDataSource : ChatDataSourceProtocol {

    var delegate: ChatDataSourceDelegateProtocol?
    var chatItems: [ChatItemProtocol] = []
    var notificationToken : NotificationToken?

    private var isFirst: Bool = true

    var conversation : Conversation? {
        didSet {
            notificationToken?.stop()
            isFirst = true
            guard let c = conversation else { return }
            let chatMessages = RChatConstants.Realms.conversations.objects(ChatMessage.self)
                .filter("conversationId = %@", c.conversationId)
                .sorted(byKeyPath: "timestamp", ascending: true)

            notificationToken = chatMessages
                .addNotificationBlock({ [weak self] (changes) in
                    guard let `self` = self else { return }
                    self.isFirst = false
                    var items = [ChatItemProtocol]()
                    for m in Array(chatMessages).map({ ChatMessage(value: $0) }) {
                        if m.mimeType == MimeType.textPlain.rawValue {
                            items.append(RChatTextMessageModel(messageModel: m))
                        }
                    }
                    self.chatItems = items
                    self.delegate?.chatDataSourceDidUpdate(self, updateType: self.isFirst ? .reload : .normal)
                })
        }
    }



    var hasMoreNext: Bool {
        return false
    }

    var hasMorePrevious: Bool {
        return false
    }

    func loadNext() {

    }

    func loadPrevious() {

    }

    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: ((Bool)) -> Void) {
        completion(false)
    }

    func sendMessage(text: String){
        guard let conversation = self.conversation else { fatalError("We are not attached to a conversation. It is nil") }
        ChatMessage.sendTextChatMessage(conversation: conversation, text: text)
    }

}
