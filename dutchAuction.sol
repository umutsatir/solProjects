// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// you should have NFT contract to use this contract!!
interface IERC721 {
    function transferFrom(address _from, address _to, uint _nftId) external;
}

contract DutchAuction {
    uint private constant DURATION = 7 days;

    IERC721 public immutable nft;
    uint public immutable nftId;

    address payable public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable expiresAt;
    uint public immutable discountRate;

    constructor(uint _startingPrice, uint _discountRate, address _nft, uint _nftId) {
        seller = payable(msg.sender);
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;
        discountRate = _discountRate;
        startingPrice = _startingPrice;

        require(_startingPrice >= _discountRate * DURATION, "starting price low");

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    function getPrice() public view returns(uint) {
        uint timeElapsed = block.timestamp - startAt;
        return startingPrice - (timeElapsed * discountRate);
    }

    function buy() external payable {
        require(expiresAt > startAt + DURATION, "time is over");
        uint price = getPrice();
        require(msg.value >= price, "insufficient amount");
        nft.transferFrom(seller, msg.sender, nftId);
        uint refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        selfdestruct(seller);
    }
}