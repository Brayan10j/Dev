<template>
  <v-container>
    <!--
    <v-file-input
      multiple
      label="File multiple input"
      v-model="multiple"
    ></v-file-input>
    -->
    <v-btn right @click="dialogCreateNFT = true">Create NFT</v-btn>
    <v-dialog v-model="dialogCreateNFT" persistent max-width="900px">
      <v-overlay :value="overlay">
        <v-progress-circular indeterminate size="64"></v-progress-circular>
      </v-overlay>
      <v-card>
        <v-card-title>
          <span class="text-h5">Create NFT</span>
        </v-card-title>
        <v-card-text>
          <v-container>
            <v-row>
              <v-col cols="8">
                <v-btn @click="singleNFT = true">Single</v-btn>
                <v-btn @click="multipleNFT = true">Multiple</v-btn>
                <v-col v-if="multipleNFT" cols="12">
                  <v-text-field
                    label="Quantity"
                    v-model.number="quantity"
                    required
                  ></v-text-field>
                </v-col>
                <v-tabs v-model="tab">
                  <v-tab v-for="item in items" :key="item.name">
                    {{ item.name }}
                  </v-tab>
                </v-tabs>
                <v-tabs-items v-model="tab">
                  <v-tab-item v-for="item in items" :key="item.name">
                    <v-file-input
                      label="File input"
                      :accept="item.accepts"
                      v-model="single"
                      @change="getFile"
                    ></v-file-input>
                    {{ item.text }}

                    <br />
                    <v-file-input
                      v-if="item.name != 'Image'"
                      label="Cover image "
                      accept=".jpeg, .jpg, .png, .gif"
                    ></v-file-input>
                  </v-tab-item>
                </v-tabs-items>
                <v-col cols="12">
                  <v-text-field
                    label="Name (Author)"
                    v-model="nftJSON.nameAuthor"
                    required
                  ></v-text-field>
                </v-col>
                <v-col cols="12">
                  <v-text-field
                    label="Name"
                    v-model="nftJSON.name"
                    required
                  ></v-text-field>
                </v-col>
                <v-col cols="12">
                  <v-textarea label="Description"></v-textarea>
                </v-col>
                <v-col cols="12">
                  <v-select
                    :items="[
                      '1 category',
                      '2 category',
                      '3 category',
                      '4 category',
                    ]"
                    label="Category"
                    required
                  ></v-select>
                </v-col>
                <v-col cols="12">
                  <v-text-field
                    label="Price (ETH)"
                    v-model="nftJSON.price"
                    required
                  ></v-text-field>
                </v-col>
                <v-col cols="12">
                  <v-slider
                    label="Royalies"
                    max="50"
                    thumb-color="red"
                    thumb-label="always"
                    v-model.number="nftJSON.royalty"
                  >
                    <template v-slot:thumb-label="{ value }">
                      {{ value }} %
                    </template></v-slider
                  >
                </v-col>
              </v-col>
              <v-col>
                <v-card class="mx-auto" max-width="344">
                  <v-img
                    :src="nftJSON.objectURL"
                    max-width="300px"
                    aspect-ratio="2"
                  ></v-img>

                  <v-card-title>
                    {{ nftJSON.name }}
                  </v-card-title>

                  <v-card-subtitle> {{ nftJSON.price }} (ETH) </v-card-subtitle>
                </v-card>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="blue darken-1" text @click="dialogCreateNFT = false">
            Close
          </v-btn>
          <v-btn color="blue darken-1" text @click="createNFT"> Save </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>
export default {
  components: {},
  data() {
    return {
      overlay: false,
      singleNFT: false,
      multipleNFT: false,
      single: null,
      singleBuffer: null,
      multiple: null,
      dialogCreateNFT: false,
      range: [0, 40],
      quantity: 1,
      tab: null,
      nftJSON: {
        objectURL: null,
        price: "0",
        royalty: 0,
        name: "",
        nameAuthor: "",
      },
      items: [
        {
          name: "Image",
          accepts: ".jpeg, .jpg, .png, .gif",
          text: "jpeg, jpg, png, gif.",
        },
        {
          name: "Video",
          accepts: ".mp4, .x-m4v",
          text: "mp4, x-m4v.",
        },
        {
          name: "Music",
          accepts: ".mp3",
          text: "mp3.",
        },
        {
          name: "3D",
          accepts: ".obj, .glb",
          text: "obj, glb.",
        },
      ],
    };
  },
  methods: {
    async getFile(e) {
      const IPFS = require("ipfs-core");
      const reader = new FileReader();
      const ipfs = await IPFS.create();
      const stream = ipfs.cat("QmPChd2hVbrJ6bfo3WBcTW4iZnpHm8TEzWkLHmLpXhF68A");
      console.log(stream);
      let data = "";
      for await (const chunk of stream) {
        // chunks of data are returned as a Buffer, convert it back to a string
        data += chunk.toString();
      }

      console.log(data);
      ipfs.stop();
      this.objectURL = URL.createObjectURL(e);
      reader.readAsArrayBuffer(e);
      reader.onload = (e) => {
        this.singleBuffer = e.target.result;
      };
    },
    async createNFT() {
      const IPFS = require("ipfs-core");
      const Web3 = require("web3");
      const abi = require("../static/ABI");

      try {
        //IPFS
        const ipfs = await IPFS.create();
        //const { cid } = await ipfs.add("Hello world");

        //console.info(cid);
        let doc = JSON.stringify(this.nftJSON);

        let { cid } = await ipfs.add(doc);

        console.log("IPFS cid:", cid);
        let result = ipfs.cat(cid);
        console.log(result);
        ipfs.stop();
        this.overlay = true;
        await window.ethereum.request({ method: "eth_requestAccounts" });
        var web3 = new Web3(Web3.givenProvider);
        let userAccount = web3.currentProvider.selectedAddress;
        var contractAddress = "0xd705aCe869e4530c9Add3ff4317CBd2F918bC0F8";
        var contract = new web3.eth.Contract(abi.default, contractAddress);
        let res = await contract.methods
          .multiple(userAccount, this.objectURL, this.quantity, this.royalty)
          .send({ from: userAccount });
        this.overlay = false;
        alert("NFT creado , you trasnsaction hash is: " + res.transactionHash);
      } catch (error) {
        this.overlay = false;
        alert(error);
      }
    },
  },
};
</script>

<style>
</style>
