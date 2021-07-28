// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.1.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.1.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.1.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.1.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.1.0/utils/Counters.sol";

contract MyToken is Ownable, ERC721URIStorage, ERC721Burnable  {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    
    // Mapping from token ID to creator address
    mapping(uint256 => address) private _creators;
    
    // Mapping from token ID to royalties
    mapping(uint256 => uint) private _royalties;

    constructor() ERC721("MyToken", "MTK") {}


    function awardItem(address player, string memory _tokenURI, uint royalties)
        public 
        returns (uint256)
    {
        _tokenIdCounter.increment();
        
        uint256 newItemId = _tokenIdCounter.current();
        _safeMint(player, newItemId);
        
        _royalties[newItemId] = royalties;
        _creators[newItemId] = player;
        _setTokenURI(newItemId, _tokenURI);


        return newItemId;
    }
    function multiple(address player, string memory _tokenURI, uint quantity, uint royalties)
        public 
        
    {
     
        for (uint i =0; i<quantity; i++) {
            awardItem(player,_tokenURI, royalties);
            
        }
        
    }
 
    function buyNFT(uint256 tokenId) public payable {
        uint porcent = msg.value *(_royalties[tokenId]/100);
        address seller = ownerOf(tokenId);
        payable(seller).transfer(msg.value - porcent);
        payable(_creators[tokenId]).transfer(porcent);
        _transfer(seller, msg.sender, tokenId);
    }
    
    function updateURI(uint256 _tokenId , string memory _tokenURI) public{
        _setTokenURI(_tokenId, _tokenURI);
    }
    
    function getAllNFTs() public view returns(string[] memory result) {
        result = new string[](_tokenIdCounter.current());
        for (uint i = 1; i <= _tokenIdCounter.current(); i++)
            if (_exists(i)){
                result[i-1] = tokenURI(i);
            }
            
        return result;
    }
    
    function getNFTsOwner() public view returns(string[] memory result) {
        result = new string[](_tokenIdCounter.current());
        for (uint i = 1; i <= _tokenIdCounter.current(); i++)
            if (_exists(i) && ownerOf(i)== msg.sender){
                result[i-1] = tokenURI(i);
            }
        return result;
    }
    
   
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
        delete _creators[tokenId];
        delete _royalties[tokenId];
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}