// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Billboard is Ownable {
    uint256 public constant MAX_MESSAGES = 5;

    struct BillboardStorage {
        Message[] messages;
        uint256 oldestIndex;
    }

    struct Message {
        address sender;
        string message;
        uint256 addedAt;
    }

    BillboardStorage private _billboard;

    event MessageAdded(address sender, string message, uint256 addedAt);

    constructor(address owner_) {
        transferOwnership(owner_);
    }

    function addMessage(string memory messageText_) external {
        Message memory message_ = Message({
            sender: msg.sender,
            message: messageText_,
            addedAt: block.timestamp
        });

        emit MessageAdded(message_.sender, message_.message, message_.addedAt);

        if (_billboard.messages.length < MAX_MESSAGES) {
            _billboard.messages.push(message_);
            return;
        }

        _billboard.messages[_billboard.oldestIndex] = message_;
        _billboard.oldestIndex = (_billboard.oldestIndex + 1) % MAX_MESSAGES;
    }

    function clear() external onlyOwner {
        delete _billboard;
    }

    function getMessages() external view returns (Message[] memory) {
        Message[] memory messages_ = _billboard.messages;

        _sort(messages_, _billboard.oldestIndex);

        return messages_;
    }

    function _sort(Message[] memory messages_, uint256 oldestIndex_) private pure {
        _reverseSlice(messages_, 0, oldestIndex_);
        _reverseSlice(messages_, oldestIndex_, messages_.length);
        _reverseSlice(messages_, 0, messages_.length);
    }

    function _reverseSlice(Message[] memory messages_, uint256 left_, uint256 right_) private pure {
        while (left_ + 1 < right_) {
            (messages_[left_], messages_[right_ - 1]) = (messages_[right_ - 1], messages_[left_]);
            ++left_;
            --right_;
        }
    }
}
