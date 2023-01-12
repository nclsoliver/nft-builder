// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.8.0/security/Pausable.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.0/utils/Counters.sol";

contract Web3Builders is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    uint256 maxSupply =2000;
    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;
    mapping(address => bool) public allowList;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Web3Builders", "WE3") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function editMintWindows(
        bool _publicMintOpen,
        bool _allowListMintOpen
    ) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    //add publicMint and allowLinstMintOpen variables
    //require only the allowList people to mint
    function allowListMint() public payable {
        require(allowListMintOpen, "Allowlist Mint Closed");
        require(allowList[msg.sender], "You are not on the allow list");
        internalMint();
    }

    //add Payment
    //add limiting of supply
    function publicMint() public payable {
        require(publicMintOpen,"Public Mint Closed");        
        require(msg.value == 0.01 ether, "Not Enough Funds");
        internalMint();
    }

    function internalMint() internal {
        require(totalSupply() < maxSupply, "We Sold Out!");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);

    }

    function withdraw(address _addr) external onlyOwner {
        //get the balance of the contract
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
    }

    //populate the allow list
    function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++){
            allowList[addresses[i]] = true;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
