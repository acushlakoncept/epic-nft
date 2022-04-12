//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string baseSvg = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><defs><linearGradient id="a" x1="0%" y1="0%" x2="100%" y2="0%" gradientTransform="rotate(30)"><stop offset="0%" style="stop-color:#6ab1c8;stop-opacity:1"/><stop offset="100%" style="stop-color:#bde9fa;stop-opacity:1"/></linearGradient></defs><rect width="100%" height="100%" fill="url(#a)"/><text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" style="fill:&quot;#032a37&quot;;font-weight:700;font-family:tahoma;font-size:16px">';

  string[] firstWords = ["Super", "Amazing", "Epic", "Crazy", "Fantastic", "Wild"];
  string[] secondWords = ["Power", "Stunt", "Chicken", "Code", "Game", "Salad"];
  string[] thirdWords = ["Naruto", "Sasuke", "Goku", "Mbre", "Esit", "Mmoyo"];

  constructor() ERC721 ("AcushlaNFT", "SQUARE") {
    console.log("This is my NFT contract. Whoa!");
  }

  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("Super", Strings.toString(tokenId))));
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("Amazing", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("Naruto", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }


  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();

    string memory firstWord = pickRandomFirstWord(newItemId);
    string memory secondWord = pickRandomSecondWord(newItemId);
    string memory thirdWord = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(firstWord, secondWord, thirdWord));

    string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            // set the title of our NFT as the generated word.
            combinedWord,
            '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
            // add data:image/svg+xml;base64 and then append our base64 encode our svg.
            Base64.encode(bytes(finalSvg)),
            '"}'
        )
      )
    ));

    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(
      string(
        abi.encodePacked(
          "https://nftpreview.0xdev.codes/?code=",
          finalTokenUri
        )
      )
    );
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);

    _setTokenURI(newItemId, finalTokenUri);
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    _tokenIds.increment();

  }
}
