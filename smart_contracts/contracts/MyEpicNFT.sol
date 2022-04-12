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

  uint private totalNftMinted;


  string baseSvg = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><defs><linearGradient id="a" x1="0%" y1="0%" x2="100%" y2="0%" gradientTransform="rotate(30)"><stop offset="0%" style="stop-color:#6ab1c8;stop-opacity:1"/><stop offset="100%" style="stop-color:#bde9fa;stop-opacity:1"/></linearGradient></defs><rect width="100%" height="100%" fill="url(#a)"/><text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" style="fill:&quot;#032a37&quot;;font-weight:700;font-family:tahoma;font-size:16px">';

  string baseSvgStart = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><defs><linearGradient id="a" x1="0%" y1="0%" x2="100%" y2="0%" gradientTransform="rotate(30)"><stop offset="0%" style="stop-color:';
  string baseSvgMid1 = ';stop-opacity:1"/><stop offset="100%" style="stop-color:';
  string baseSvgMid2 = ';stop-opacity:1"/></linearGradient></defs><rect width="100%" height="100%" fill="url(#a)"/><text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" style="fill:&quot;#032a37&quot;;font-weight:700;font-family:tahoma;font-size:16px">';
  string baseSvgEnd = '</text></svg>';

  string[] firstWords = ["Super", "Amazing", "Epic", "Crazy", "Fantastic", "Wild"];
  string[] secondWords = ["Power", "Stunt", "Chicken", "Code", "Game", "Salad"];
  string[] thirdWords = ["Naruto", "Sasuke", "Goku", "Mbre", "Esit", "Mmoyo"];

  string[] colorsFrom = ["#6ab1c8", "#08C2A8", "#60c657", "orange", "blue", "green"];
  string[] colorsTo = ["#bde9fa", "#08C2A8", "#35aee2", "yellow", "#6ab1c8", "green"];

  event NewEpicNFTMinted(address sneder, uint256 tokenId);

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

  function pickRandomColorFrom(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
    rand = rand % colorsFrom.length;
    return colorsFrom[rand];
  }

  function pickRandomColorTo(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("COLOURS", Strings.toString(tokenId))));
    rand = rand % colorsTo.length;
    return colorsTo[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  function getTotalNFTMinted() public view returns (uint) {
    return totalNftMinted;
  }

  


  function makeAnEpicNFT() public {
    require(totalNftMinted < 51, "NFT minted limit reached");

    uint256 newItemId = _tokenIds.current();

    string memory firstWord = pickRandomFirstWord(newItemId);
    string memory secondWord = pickRandomSecondWord(newItemId);
    string memory thirdWord = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(firstWord, secondWord, thirdWord));

    string memory randomColorFrom = pickRandomColorFrom(newItemId);
    string memory randomColorTo = pickRandomColorTo(newItemId);

    string memory finalSvg = string(abi.encodePacked(baseSvgStart, randomColorFrom, baseSvgMid1, randomColorTo, baseSvgMid2, combinedWord, baseSvgEnd));

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

    console.log("Total minted:", totalNftMinted);

    _tokenIds.increment();
    totalNftMinted++;

    NewEpicNFTMinted(msg.sender, newItemId);

  }
}
