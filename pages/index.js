import Head from 'next/head'
import Image from 'next/image'
import { useEffect, useState } from 'react';
import twitterLogo from '../assets/twitter-logo.svg';
import myEpicNft from '../utils/MyEpicNFT.json';
import { ethers } from 'ethers';
import HashLoader from 'react-spinners/HashLoader';
import Link from 'next/link';

// Constants
const TWITTER_HANDLE = '_buildspace';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
const OPENSEA_LINK = '';
const TOTAL_MINT_COUNT = 50;
const CONTRACT_ADDRESS = '0x5CDF68875aBA58c1Cc6a961DbB98dcD3D6bBB24C';

export default function Home() {
  const [currentAccount, setCurrentAccount] = useState("");
  const [loading, setLoading] = useState(false);
  const [testnetAddress, setTestnetAddress] = useState("");
  const [openseaAddress, setOpenseaAddress] = useState("");

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

    setupEventListener();
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

     setupEventListener();
   } catch (error) {
     console.log(error)
   }
 }

 const setupEventListener = async () => {
   try {
     const { ethereum } = window;
     if(ethereum){
       const provider = new ethers.providers.Web3Provider(ethereum);
       const signer = provider.getSigner();
       const connectedContract = new ethers.Contract(CONTRACT_ADDRESS, myEpicNft.abi, signer);

       connectedContract.on("NewEpicNFTMinted", (from, tokenId) => {
         console.log(from, tokenId.toNumber());
         
         setOpenseaAddress(`https://testnets.opensea.io/assets/${CONTRACT_ADDRESS}/${tokenId.toNumber()}`);
       });

       console.log("Setup event listener");
     } else {
      console.log("Ethereum object doesn't exist!");
     }
   } catch (error) {
     console.log(error);
   }
 }

 const resetLinks = () => {
  setOpenseaAddress("");
  setTestnetAddress("");
 }

 const askContractToMintNft = async () => {
  setLoading(true);
  resetLinks();
   try {
     const { ethereum } = window;

     if(ethereum) {
       const provider = new ethers.providers.Web3Provider(ethereum);
       const signer = provider.getSigner();
       const connectedContract = new ethers.Contract(CONTRACT_ADDRESS, myEpicNft.abi, signer);
       setLoading(true);
       console.log("Going to pop wallet now to pay gas...");
       let nftTxn = await connectedContract.makeAnEpicNFT();

       console.log("Mining... please wait.");
       await nftTxn.wait();
       setLoading(false);
       console.log(nftTxn)
       console.log(`Mined, see traction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);
       setTestnetAddress(`https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);
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
    resetLinks();
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
                {loading ?
                  (
                  <>
                    <HashLoader color='#fff' size={'20px'} />
                    <span className='pl-4'>Currently minting your NFT</span> 
                  </> 
                  ):
                 "Mint NFT"
                }
              </button>
            )
          }

          { testnetAddress !== "" &&
            <p className="mt-5 mx-auto text-gray-300 text-md w-[20rem] text-center truncate">
            <span className='font-bold'>Rinkeby Etherscan Address:</span> <br /> 
            <Link href={testnetAddress} >
              <a className="text-green-500 truncate" target="_blank" rel="noopener noreferrer">
                {testnetAddress}
              </a>
            </Link>
            </p>
          }
          { openseaAddress !== "" &&
            <p className="mt-12 mx-auto text-gray-300 text-md w-[30rem] text-center truncate">
              Hey there! We&apos;ve minted your NFT and sent it to your wallet. It may be blank right now. It can take a max of 10 min to show up on OpenSea. <br />
              Here&apos;s the OpenSea link: <br /> 
            <Link href={openseaAddress}>
            <a className="text-green-500" target="_blank" rel="noopener noreferrer">
              {openseaAddress}
            </a>
            </Link>
            </p>
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
