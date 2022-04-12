import Head from 'next/head'
import Image from 'next/image'
import { useEffect, useState } from 'react';
import twitterLogo from '../assets/twitter-logo.svg';
import myEpicNft from '../utils/MyEpicNFT.json';
import { ethers } from 'ethers';

// Constants
const TWITTER_HANDLE = '_buildspace';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
const OPENSEA_LINK = '';
const TOTAL_MINT_COUNT = 50;

export default function Home() {
  const [currentAccount, setCurrentAccount] = useState("");

 const checkIfWallectIsConnected = async () => {
  const { ethereum } = window;

  if(!ethereum) {
    console.log("Make sure you have metamask!");
    return;
  } else {
    console.log("We have the ethereum object", ethereum);
  }

  const accounts = await ethereum.request({ method: 'eth_accounts' });

  if(accounts.length !== 0) {
    const account = accounts[0];
    console.log('Found an authorized account:', account);
    setCurrentAccount(account);
  } else {
    console.log('No authorized account found');
  }
 }

 const connectWallet = async () => {
   try {
     const { ethereum } = window;
     if(!ethereum){
       alert("Please install MetaMask to use this app!");
       return;
     }

     const accounts = await ethereum.request({ method: 'eth_requestAccounts' });

     console.log("Connected", accounts[0]);
     setCurrentAccount(accounts[0]);
   } catch (error) {
     console.log(error)
   }
 }

 const askContractToMintNft = async () => {
   const CONTRACT_ADDRESS = '0xFAE302644E2920076b772bDad4804DEDA0161966';

   try {
     const { ethereum } = window;

     if(ethereum) {
       const provider = new ethers.providers.Web3Provider(ethereum);
       const signer = provider.getSigner();
       const connectedContract = new ethers.Contract(CONTRACT_ADDRESS, myEpicNft.abi, signer);

       console.log("Going to pop wallet now to pay gas...");
       let nftTxn = await connectedContract.makeAnEpicNFT();

       console.log("Mining... please wait.");
       await nftTxn.wait();

       console.log(`Mined, see traction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);
     } else {
       console.log("No ethereum object found");
     }
   } catch (error) {
     console.log(error);
   }
 }

  const renderNotConnectedContainer = () => (
    <button className="cta-button connect-wallet-button">
      Connect to Wallet
    </button>
  );

  useEffect(() => {
    checkIfWallectIsConnected();
  }, [])

  return (
    <div className="w-screen h-screen overflow-scroll bg-[#0d1116] text-center">
      <div className="flex flex-col h-full justify-between">
        <div className="pt-[4rem]">
          <p className="header gradient-text">My NFT Collection</p>
          <p className="sub-text">
            Each unique. Each beautiful. Discover your NFT today.
          </p>
          { currentAccount === "" ?
            renderNotConnectedContainer() :
            (
              <button 
                onClick={askContractToMintNft}
                className="cta-button connect-wallet-button">
                Mint NFT
              </button>
            )
          }
        </div>
        <div className="footer-container">
          <Image alt="Twitter Logo" className="twitter-logo" src={twitterLogo} />
          <a
            className="footer-text"
            href={TWITTER_LINK}
            target="_blank"
            rel="noreferrer"
          >{`built on @${TWITTER_HANDLE}`}</a>
        </div>
      </div>
    </div>
  );
}
