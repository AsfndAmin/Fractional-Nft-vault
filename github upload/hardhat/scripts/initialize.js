const Web3 = require("web3");
const Tx = require('ethereumjs-tx').Transaction
const rpcUrl = "https://ropsten.infura.io/v3/9d3abb594bbb4be99e86186d3d9e87de";
const web3 = new Web3(rpcUrl);

const account1 = "0xeA29891b492Bd2bb13ab2a57C35650762D2d38e4";
const privateKey = "a40289fe12e7209a24790db12ea43fa0bd58a0c5c0741e98fc7b271df7afd148";
const privateKey1 = Buffer.from(privateKey, "hex");

const contractAddress = "0x548c44FE1BDD4DED8afA2EB17F48CA1ad0FBbaa5";
const contractabi = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_blackListAddress",
				"type": "address"
			}
		],
		"name": "addBlacklist",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_whiteListAddress",
				"type": "address"
			}
		],
		"name": "addWhitelist",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "previousAdmin",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "newAdmin",
				"type": "address"
			}
		],
		"name": "AdminChanged",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "beacon",
				"type": "address"
			}
		],
		"name": "BeaconUpgraded",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_shares",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_totalAmount",
				"type": "uint256"
			}
		],
		"name": "buyShare",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			}
		],
		"name": "claimRemainingShareToken",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "nftOwner",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "unSoldAmount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "claimTime",
				"type": "uint256"
			}
		],
		"name": "ClaimUnSoldToken",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_symbol",
				"type": "string"
			},
			{
				"internalType": "address",
				"name": "_token",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_supply",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_unitPrice",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_preSaleStartTime",
				"type": "uint256"
			},
			{
				"internalType": "uint16",
				"name": "_ownerRoyalty",
				"type": "uint16"
			},
			{
				"internalType": "uint8",
				"name": "_paymentIndx",
				"type": "uint8"
			}
		],
		"name": "fractionalizeNft",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "nftOwner",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "share",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "unitPrice",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "nftAddress",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "nftId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "shareToken",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "preSaleStartTime",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "preSaleEndTime",
				"type": "uint256"
			}
		],
		"name": "FractionalizeNft",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_fee",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "_liquidityWallet",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_holdoutPeriod",
				"type": "uint256"
			}
		],
		"name": "initialize",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint8",
				"name": "version",
				"type": "uint8"
			}
		],
		"name": "Initialized",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "",
				"type": "bytes"
			}
		],
		"name": "onERC721Received",
		"outputs": [
			{
				"internalType": "bytes4",
				"name": "",
				"type": "bytes4"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "previousOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "renounceOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_fee",
				"type": "uint256"
			}
		],
		"name": "setfee",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint8",
				"name": "index",
				"type": "uint8"
			},
			{
				"internalType": "address",
				"name": "_paymentToken",
				"type": "address"
			}
		],
		"name": "setPaymentToken",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint16",
				"name": "_companyShare",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_creatorShare",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_liquidityShare",
				"type": "uint16"
			}
		],
		"name": "setShareRatio",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "buyer",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "shareAmount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "currencyAmount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "nftAddress",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "nftId",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "shareToken",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "buyTime",
				"type": "uint256"
			}
		],
		"name": "ShareSold",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "implementation",
				"type": "address"
			}
		],
		"name": "Upgraded",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newImplementation",
				"type": "address"
			}
		],
		"name": "upgradeTo",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newImplementation",
				"type": "address"
			},
			{
				"internalType": "bytes",
				"name": "data",
				"type": "bytes"
			}
		],
		"name": "upgradeToAndCall",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_amount",
				"type": "uint256"
			}
		],
		"name": "calculateShare",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "companyShare",
		"outputs": [
			{
				"internalType": "uint16",
				"name": "",
				"type": "uint16"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "fee",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			}
		],
		"name": "getPaymentToken",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getShareRatio",
		"outputs": [
			{
				"internalType": "uint16",
				"name": "",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "",
				"type": "uint16"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			}
		],
		"name": "getVault",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "nftOwner",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "shareToken",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "nftAddress",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "nftId",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "unitPrice",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "preSaleStartTime",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "preSaleEndTime",
						"type": "uint256"
					},
					{
						"internalType": "uint8",
						"name": "paymentIndx",
						"type": "uint8"
					}
				],
				"internalType": "struct FractionalNftVault.Item",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "liquidityShare",
		"outputs": [
			{
				"internalType": "uint16",
				"name": "",
				"type": "uint16"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "liquidityWallet",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "proxiableUUID",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "vaultCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]

const contractMehodAsync = async () => {
  try {
    const contract = new web3.eth.Contract(contractabi, contractAddress);
    const txCount = await web3.eth.getTransactionCount(account1);
    const txObj = {
        nonce: web3.utils.toHex(txCount),
        to: contractAddress,
        data: contract.methods.initialize(20,"0xeA29891b492Bd2bb13ab2a57C35650762D2d38e4",9999 ).encodeABI(),
        gasLimit: web3.utils.toHex(100000),
        gasPrice: web3.utils.toHex(web3.utils.toWei("10", "gwei"))
    }


  const tx = new Tx(txObj)
  tx.sign(privateKey1)

  const serializedTx = tx.serialize();
  const raw = "0x" + serializedTx.toString('hex');
  const signedTransaction = await web3.eth.sendSignedTransaction(raw);
  console.log("signedTransaction", signedTransaction)
  await contract.methods.balanceOf(account1).call((err, result) => { console.log(result) })
await contract.methods.balanceOf(account2).call((err, result) => { console.log(result) })
}
catch (error) {
  console.log("error", error)
}
}

contractMehodAsync()

