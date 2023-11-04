// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AppStorage, PostFlagType } from "../libraries/LibAppStorage.sol";

contract ContentFacet {
    AppStorage internal s;

    error AlreadyLiked();
    error AlreadyDisliked();
    error InvalidParentPostId();

    event Post(address indexed author, uint256 indexed postId, uint256 createdAt, string content, uint256 parentPostId);
    event PostLike(address indexed author, uint256 indexed postId, uint256 indexed likeId, uint256 createdAt);
    event PostRepost(
        address indexed author, uint256 indexed originalPostId, uint256 indexed repostId, uint256 createdAt
    );
    event PostDislike(address indexed author, uint256 indexed postId, uint256 createdAt);

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
        uint256 _id = s.postCountOf[msg.sender] + 1; // Increment post count
        s.postCountOf[msg.sender] = _id;
        emit Post(msg.sender, _id, block.timestamp, _content, 0);
    }

    function postReply(string calldata _content, uint256 _parentPostId) external {
        if (_parentPostId == 0) {
            revert InvalidParentPostId();
        }
        uint256 _id = s.postCountOf[msg.sender] + 1; // Increment post count
        s.postCountOf[msg.sender] = _id;
        s.postReplyCountOf[_id] = _id + 1; // Increment reply count
        emit Post(msg.sender, _id, block.timestamp, _content, _parentPostId);
    }

    function like(uint256 _postId) external {
        bool isLiked = s.likedPostsOf[msg.sender][_postId];
        if (isLiked) {
            revert AlreadyLiked();
        }
        emit PostLike(msg.sender, _postId, 0, block.timestamp);
    }

    function repost(uint256 _originalPostId) external {
        uint256 _id = s.postCountOf[msg.sender];
        s.postCountOf[msg.sender] = _id + 1; // Increment post count
        emit PostRepost(msg.sender, _originalPostId, _id, block.timestamp);
    }

    function dislike(uint256 _postId) external {
        bool isDisliked = s.dislikedPostsOf[msg.sender][_postId];
        if (isDisliked) {
            revert AlreadyDisliked();
        }
        s.dislikedPostsOf[msg.sender][_postId] = true;
        s.postDislikeCountOf[_postId] += 1;
        emit PostDislike(msg.sender, _postId, block.timestamp);
    }

    function flagPost(uint256 _postId, PostFlagType _flag) external {
        s.postFlags[_postId] = _flag;
    }
}
