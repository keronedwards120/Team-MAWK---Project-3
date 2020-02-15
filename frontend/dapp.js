// Change this address to match your deployed contract!
const contract_address = "0x7A8DF91Ba10F548593b1ff1BE47577EeA2656B9d";

const dApp = {
  ethEnabled: function() {
    // If the browser has MetaMask installed
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      window.ethereum.enable();
      return true;
    }
    return false;
  },
  collectVars: async function(){
    this.tokens = [];
    this.totalSupply = await this.marsContract.methods.totalSupply().call();

    const fetchMetadata = (reference_uri) => fetch(`https://gateway.pinata.cloud/ipfs/${reference_uri.replace("ipfs://", "")}`, { mode: "cors" }).then((resp) => resp.json());
    for (let i = 1; i <= this.totalSupply; i++) {
      try {
        const token_uri = await this.marsContract.methods.tokenURI(i).call();
        //console.log('token uri', token_uri)
        const token_json = await fetchMetadata(token_uri);
        //console.log('token json', token_json)
        this.tokens.push({
          tokenId: i,
          highestBid: Number(await this.marsContract.methods.highestBid(i).call()),
          auctionEnded: Boolean(await this.marsContract.methods.auctionEnded(i).call()),
          pendingReturn: Number(await this.marsContract.methods.pendingReturn(i, this.accounts[0]).call()),
          owner: await this.marsContract.methods.ownerOf(i).call(),
          uri:token_uri,
          //verify:false,
          ...token_json
        });
      } catch (e) {
        console.log(JSON.stringify(e));
      }
    }
  },
  setAdmin: async function() {
    // if account selected in MetaMask is the same as owner then admin will show
    if (this.isAdmin) {
      $(".dapp-admin").show();
    } else {
      $(".dapp-admin").hide();
    }
  },
  sendtoHouse: async function(){
    await this.collectVars();
    let tokenId = (this.tokens.length)-1;
    let token = this.tokens[tokenId];
    //token.verify = false;
    //console.log(token.verify);
    //console.log(token);
    let name = token.name;
    let image = token.image;
    $("#dapp-auctionHouse").append(
      `<li id="auction-house-list${token.tokenId}">
        <div class="collapsible-header"><img src="https://gateway.pinata.cloud/ipfs/${image.replace("ipfs://", "")}" width="35" height="35">Auction Item ${token.tokenId}: ${name}</div>
        <div class="collapsible-body">
          <img src="https://gateway.pinata.cloud/ipfs/${image.replace("ipfs://", "")}" style="width: 100%" />
          <button id="${token.tokenId}" onclick="dApp.verify(event)">Verify</button>
        </div>
      </li>`
    );
  },
  verify: async function(event){
    const tokenId = $(event.target).attr("id");
    await this.marsContract.methods.verify(tokenId).send({from: this.accounts[0]}, async () => {
      await this.collectVars();
      let token = this.tokens[tokenId-1];
      token.verify=true;
      let name = token.name;
      let image = token.image;
      let endAuction = `<a id="${token.tokenId}" class="dapp-admin" style="display:none;" href="#" onclick="dApp.endAuction(event)">End Auction</a>`;
      let bid = `<a id="${token.tokenId}" href="#" onclick="dApp.bid(event);">Bid</a>`;
      let owner = `Owner: ${token.owner}`;
      let withdraw = `<a id="${token.tokenId}" data-uri="${token.uri}" href="#" onclick="dApp.withdraw(event)">Withdraw</a>`
      let pendingWithdraw = `Balance: ${token.pendingReturn} wei`;
      $("#dapp-bidder").append(
        `<li id="bidder-list${token.tokenId}">
          <div class="collapsible-header"><img src="https://gateway.pinata.cloud/ipfs/${image.replace("ipfs://", "")}" width="35" height="35">Auction Item ${token.tokenId}: ${name}</div>
          <div class="collapsible-body">
            <img src="https://gateway.pinata.cloud/ipfs/${image.replace("ipfs://", "")}" style="width: 100%" />
            <input type="number" min="${token.highestBid + 1}" name="dapp-wei" value="${token.highestBid + 1}" ${token.auctionEnded ? 'disabled' : ''}>
            ${token.auctionEnded ? owner : bid}
            ${token.pendingReturn > 0 ? withdraw : ''}
            ${token.pendingReturn > 0 ? pendingWithdraw : ''}
            ${this.isAdmin && !token.auctionEnded ? endAuction : ''}
          </div>
        </li>`
      );
    });    
    $(`#auction-house-list${tokenId}`).hide();

  },
  updateUI: async function() {
    this.setAdmin();  
    await this.collectVars();
    $("#dapp-bidder").html("");
    this.tokens.forEach((token) => {
      console.log(token.verify);
      let name = token.name;
      let image = token.image;
      let endAuction = `<a id="${token.tokenId}" class="dapp-admin" style="display:none;" href="#" onclick="dApp.endAuction(event)">End Auction</a>`;
      let bid = `<a id="${token.tokenId}" href="#" onclick="dApp.bid(event);">Bid</a>`;
      let owner = `Owner: ${token.owner}`;
      let withdraw = `<a id="${token.tokenId}" data-uri="${token.uri}" href="#" onclick="dApp.withdraw(event)">Withdraw</a>`
      let pendingWithdraw = `Balance: ${token.pendingReturn} wei`;
      if (token.verify){
        $("#dapp-bidder").append(
          `<li id="bidder-list${token.tokenId}">
            <div class="collapsible-header"><img src="https://gateway.pinata.cloud/ipfs/${image.replace("ipfs://", "")}" width="35" height="35">Auction Item ${token.tokenId}: ${name}</div>
            <div class="collapsible-body">
              <img src="https://gateway.pinata.cloud/ipfs/${image.replace("ipfs://", "")}" style="width: 100%" />
              <input type="number" min="${token.highestBid + 1}" name="dapp-wei" value="${token.highestBid + 1}" ${token.auctionEnded ? 'disabled' : ''}>
              ${token.auctionEnded ? owner : bid}
              ${token.pendingReturn > 0 ? withdraw : ''}
              ${token.pendingReturn > 0 ? pendingWithdraw : ''}
              ${this.isAdmin && !token.auctionEnded ? endAuction : ''}
            </div>
          </li>`
        );
      }else{
        $("#dapp-auctionHouse").append(
          `<li id="auction-house-list${token.tokenId}">
            <div class="collapsible-header"><img src="https://gateway.pinata.cloud/ipfs/${image.replace("ipfs://", "")}" width="35" height="35">Auction Item ${token.tokenId}: ${name}</div>
            <div class="collapsible-body">
              <img src="https://gateway.pinata.cloud/ipfs/${image.replace("ipfs://", "")}" style="width: 100%" />
              <button id="${token.tokenId}" onclick="dApp.verify(event)">Verify</button>
            </div>
          </li>`
        );
      }
    });
    //this.setAdmin();  
    
  },
  register: async function() {
    const name = $("#dapp-copyright-name").val();
    //const description = $("#dapp-copyright-description").val();
    const image = document.querySelector('input[type="file"]');

    const pinata_api_key = $("#dapp-pinata-api-key").val();
    const pinata_secret_api_key = $("#dapp-pinata-secret-api-key").val();

    if (!pinata_api_key || !pinata_secret_api_key || !name || !image) {
      M.toast({ html: "Please fill out then entire form!" });
      return;
    }

    const image_data = new FormData();
    image_data.append("file", image.files[0]);
    image_data.append("pinataOptions", JSON.stringify({cidVersion: 1}));
    
    try {
      M.toast({ html: "Uploading Image to IPFS via Pinata..." });
      const image_upload_response = await fetch("https://api.pinata.cloud/pinning/pinFileToIPFS", {
        method: "POST",
        mode: "cors",
        headers: {
          pinata_api_key,
          pinata_secret_api_key
        },
        body: image_data,
      });

      const image_hash = await image_upload_response.json();
      const image_uri = `ipfs://${image_hash.IpfsHash}`;

      M.toast({ html: `Success. Image located at ${image_uri}.` });
      M.toast({ html: "Uploading JSON..." });

      const reference_json = JSON.stringify({
        pinataContent: {name, image: image_uri },
        pinataOptions: {cidVersion: 1}
      });

      const json_upload_response = await fetch("https://api.pinata.cloud/pinning/pinJSONToIPFS", {
        method: "POST",
        mode: "cors",
        headers: {
          "Content-Type": "application/json",
          pinata_api_key,
          pinata_secret_api_key
        },
        body: reference_json
      });

      const reference_hash = await json_upload_response.json();
      const reference_uri = `ipfs://${reference_hash.IpfsHash}`;

      M.toast({ html: `Success. Reference URI located at ${reference_uri}.` });
      M.toast({ html: "Sending to blockchain..." });

      // if ($("#dapp-opensource-toggle").prop("checked")) {
      //   this.contract.methods.openSourceWork(reference_uri).send({from: this.accounts[0]})
      //   .on("receipt", (receipt) => {
      //     M.toast({ html: "Transaction Mined! Refreshing UI..." });
      //     location.reload();
      //   });
      // } else {
      //   this.contract.methods.copyrightWork(reference_uri).send({from: this.accounts[0]})
      //   .on("receipt", (receipt) => {
      //     M.toast({ html: "Transaction Mined! Refreshing UI..." });
      //     location.reload();
      //   });
      // }

      await this.marsContract.methods.registerLand(reference_uri).send({from: this.accounts[0]}, async () => {
        $("#dapp-copyright-name").val("");
        $("#dapp-copyright-image").val("");
        await this.sendtoHouse();
      });

    } catch (e) {
      alert("ERROR:", JSON.stringify(e));
    }
  },
  bid: async function(event) {
    const tokenId = $(event.target).attr("id");
    const wei = Number($(event.target).prev().val());
    await this.marsContract.methods.bid(tokenId).send({from: this.accounts[0], value: wei}, async () => {
      await this.updateUI();
    });
  },
  endAuction: async function(event) {
    const tokenId = $(event.target).attr("id");
    await this.marsContract.methods.endAuction(tokenId).send({from: this.accounts[0]}, async () => {
      await this.updateUI();
    });
  },
  withdraw: async function(event) {
    const tokenId = $(event.target).attr("id");
    const uri=$(event.target).attr("data-uri");
    console.log(uri);
    await this.marsContract.methods.withdraw(tokenId).send({from: this.accounts[0]}, async() => {
      await this.updateUI();
    });
  },
  main: async function() {
    // Initialize web3
    if (!this.ethEnabled()) {
      alert("Please install MetaMask to use this dApp!");
    }

    this.accounts = await window.web3.eth.getAccounts();
    this.contractAddress = contract_address;
    this.marsJson = await (await fetch("./MartianMarket.json")).json();

    this.marsContract = new window.web3.eth.Contract(
      this.marsJson,
      this.contractAddress,
      { defaultAccount: this.accounts[0] }
    );
    //console.log("Contract object", this.contract);
    this.isAdmin = this.accounts[0] == await this.marsContract.methods.owner().call();
    console.log(this.isAdmin);
    await this.updateUI();
  }
};

dApp.main();