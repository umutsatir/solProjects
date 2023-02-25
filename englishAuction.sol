// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// you should have NFT contract to use this contract!!
interface IERC721 {
    function safeTransferFrom(address from, address to, uint tokenId) external;
    function transferFrom(address, address, uint) external;
}

contract EnglishAuction {
    // events
    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed to, uint amount);
    event End(address winner, uint amount);
    // variables
    IERC721 public nft;
    uint public nftId;
    uint public startAt;
    uint public endAt;
    address payable public seller;
    bool public started;
    bool public ended;
    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public bids;
    // constructor
    constructor(address _nft, uint _nftId, uint _startingBid) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        highestBid = _startingBid;
    }
    // start func
    function start() public {
        require(!started, "already started");
        require(msg.sender == seller, "not seller");
        nft.transferFrom(msg.sender, address(this), nftId);
        started = true;
        endAt = startAt + 7 days;

        emit Start();
    }
    // withdraw func
    function withdraw() public {
        uint bal = bids[msg.sender];
        require(bal < highestBid, "your bid is highest");
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);
        
        emit Withdraw(msg.sender, bal);
    }
    // bid func
    function bid() public payable {
        require(started, "not started");
        require(endAt < block.timestamp, "ended");
        require(msg.value < highestBid, "bid is not enough");

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit Bid(msg.sender, msg.value);
    }
    // end func
    function end() public {
        require(started, "not started");
        require(!ended, "already ended");
        require(block.timestamp >= endAt, "not ended");

        ended = true;
        if(highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        }
        else{
            nft.safeTransferFrom(address(this), seller, nftId);
        }
        emit End(highestBidder, highestBid);
    }
}