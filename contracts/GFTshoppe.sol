// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GFTShoppe is ERC721Enumerable, Ownable {
    using Strings for *;

    mapping(address => uint256) public tokenCounters;

    string public baseTokenURI;
    uint256 public mintPrice = 0.02 ether;
    uint256 public maxMintCount = 5;
    uint256 public maxTotalSupply =10000;
    bool public isReaveled = false;

    event SetBaseURI(address _from, string value);
    event CreatedItem(address _from, uint256 _tokenId);
    event RevealOpensea(address _from);
    event Withdraw(address _from, uint amount);
    event SetMintPrice(address _from, uint256 price);
    event SetMaxMintCount(address _from, uint256 count);

    constructor(string memory _baseUri) ERC721("GFT Shoppe", "GFTShoppe") {
        baseTokenURI = _baseUri;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        baseTokenURI = baseURI;
        emit SetBaseURI(msg.sender, baseURI);
    }

    function createItem(uint256 amount) external payable {
        uint256 supply = totalSupply();
        require(amount > 0, "Mint amount can't be zero");
        require(supply + amount <= maxTotalSupply, "Max mint amount is reached");
        require(
            tokenCounters[msg.sender] + amount <= maxMintCount,
            "Exceed the Max Amount to mint."
        );
        require(amount * mintPrice == msg.value, "Price must be 0.02 eth for each NFT");
        for (uint256 i = 0; i < amount; i++) {
            _safeMint(msg.sender , supply + i);
        }
        tokenCounters[msg.sender] = tokenCounters[msg.sender] + amount;
        emit CreatedItem(msg.sender, totalSupply());
    }

    function createTeamItem(uint256 amount) external onlyOwner {
        uint256 supply = totalSupply();
        require(supply + amount <= maxTotalSupply, "Max mint amount is reached");
        
        for (uint256 i = 0; i < amount; i++) {
            _safeMint(msg.sender , supply + i);
        }
        tokenCounters[msg.sender] = tokenCounters[msg.sender] + amount;
    }

    function setRevealOpenSea() external onlyOwner {
        isReaveled = !isReaveled;
        emit RevealOpensea(msg.sender);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        emit Withdraw(msg.sender, balance);
    }

    function setMintPrice(uint256 price) external onlyOwner {
        mintPrice = price;
        emit SetMintPrice(msg.sender, price);
    }

    function setMaxMintCount(uint256 count) external onlyOwner {
        maxMintCount = count;
        emit SetMaxMintCount(msg.sender, count);
    }

    function walletOfUser(address user) external view returns(uint256[] memory) {
        uint256 tokenCount = 0;
        uint256[] memory tokensId = new uint256[](0);

        tokenCount = balanceOf(user);
        if (tokenCount > 0) {
            tokensId = new uint256[](tokenCount);
            for(uint256 i = 0; i < tokenCount; i++){
                tokensId[i] = tokenOfOwnerByIndex(user, i);
            }
        }
        return tokensId;
    }
}