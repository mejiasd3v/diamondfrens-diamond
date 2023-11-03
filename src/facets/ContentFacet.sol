// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AppStorage } from "../libraries/LibAppStorage.sol";

contract ContentFacet {
    AppStorage internal s;

    error AlreadyLiked();

    event Post(address indexed author, uint256 indexed postId, uint256 createdAt, string content);
    event PostLike(address indexed author, uint256 indexed postId, uint256 indexed likeId, uint256 createdAt);
    event PostReply(
        address indexed author, uint256 indexed postId, uint256 indexed replyId, uint256 createdAt, string content
    );
    event PostRepost(
        address indexed author, uint256 indexed originalPostId, uint256 indexed repostId, uint256 createdAt
    );

    // Getters
    function postCountOf(address _user) external view returns (uint256) {
        return s.postCountOf[_user];
    }

    function postLikeCountOf(uint256 _postId) external view returns (uint256) {
        return s.postLikeCountOf[_postId];
    }

    function postReplyCountOf(uint256 _postId) external view returns (uint256) {
        return s.postReplyCountOf[_postId];
    }

    function post(string calldata _content) external {
        uint256 _id = s.postCountOf[msg.sender];
        s.postCountOf[msg.sender] = _id + 1; // Increment post count
        emit Post(msg.sender, _id, block.timestamp, _content);
    }

    function like(uint256 _postId) external {
        bool isLiked = s.likedPostsOf[msg.sender][_postId];
        if (isLiked) {
            revert AlreadyLiked();
        }
        emit PostLike(msg.sender, _postId, 0, block.timestamp);
    }

    function reply(uint256 _postId, string calldata _content) external {
        uint256 _id = s.postReplyCountOf[_postId];
        s.postReplyCountOf[_postId] = _id + 1; // Increment reply count
        emit PostReply(msg.sender, _postId, _id, block.timestamp, _content);
    }

    function repost(uint256 _originalPostId) external {
        uint256 _id = s.postCountOf[msg.sender];
        s.postCountOf[msg.sender] = _id + 1; // Increment post count
        emit PostRepost(msg.sender, _originalPostId, _id, block.timestamp);
    }
}
