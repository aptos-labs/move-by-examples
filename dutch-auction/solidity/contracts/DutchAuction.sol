// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DutchAuction is Ownable, ERC721 {
    string private constant DUTCH_AUCTION_COLLECTION_NAME = "DUTCH_AUCTION_NAME";
    string private constant DUTCH_AUCTION_COLLECTION_SYMBOL = "DUTCH_AUCTION_SYMBOL";
    string private constant DUTCH_AUCTION_COLLECTION_URI = "DUTCH_AUCTION_URI";

    struct Auction {
        IERC20 buyToken;
        uint256 maxPrice;
        uint256 minPrice;
        uint256 duration;
        uint256 startedAt;
    }

    mapping(uint256 nftId => Auction auction) private _auctions;

    event AuctionCreated(uint256 nftId);

    constructor() ERC721(DUTCH_AUCTION_COLLECTION_NAME, DUTCH_AUCTION_COLLECTION_SYMBOL) {}

    function startAuction(
        uint256 nftId_,
        IERC20 buyToken_,
        uint256 maxPrice_,
        uint256 minPrice_,
        uint256 duration_
    ) external onlyOwner {
        require(maxPrice_ >= minPrice_, "DutchAuction: invalid prices");
        require(duration_ > 0, "DutchAuction: zero duration");

        _mint(address(this), nftId_);

        _auctions[nftId_] = Auction(buyToken_, maxPrice_, minPrice_, duration_, block.timestamp);

        emit AuctionCreated(nftId_);
    }

    function bid(uint256 nftId_) external {
        require(ownerOf(nftId_) == address(this), "DutchAuction: invalid auction");

        Auction memory auction_ = _auctions[nftId_];

        uint256 price_ = _mustHavePrice(auction_);

        transferFrom(address(this), msg.sender, nftId_);
        auction_.buyToken.transferFrom(msg.sender, address(this), price_);
    }

    function _mustHavePrice(Auction memory auction_) internal view returns (uint256) {
        require(block.timestamp <= auction_.startedAt + auction_.duration, "DutchAuction: outdated");

        uint256 timePassed_ = block.timestamp - auction_.startedAt;
        uint256 discount_ = ((auction_.maxPrice - auction_.minPrice) * timePassed_) / auction_.duration;

        return auction_.maxPrice - discount_;
    }

    function getAuction(uint256 nftId_) external view returns (Auction memory auction_) {
        return _auctions[nftId_];
    }

    function _baseURI() internal pure override returns (string memory) {
        return DUTCH_AUCTION_COLLECTION_URI;
    }
}
