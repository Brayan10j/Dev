<template>
  <v-container>
    <v-btn right @click="dialogCreateNFT = true">Create NFT</v-btn>
    <v-btn right @click="showNFTs">Show NFTs</v-btn>
    <v-col v-for="(item , index ) in listNFTs" :key="index">
      <v-card class="mx-auto" max-width="344">
        <v-img :src="item.image" max-width="300px" aspect-ratio="2"></v-img>

        <v-card-title>
          {{ item.name }}
        </v-card-title>

        <v-card-subtitle> {{ item.price }} (ETH) </v-card-subtitle>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="blue darken-1" text  :href="item.image" target="_blank">
            Ver en IPFS
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-col>
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
                <v-btn @click="multipleNFT = false">Single</v-btn>
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
                    :src="objectURL"
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
const Web3 = require("web3");
const abi = require("../static/ABI");
const contractAddress = "0x872204375A0CaFc3DC0efBD16a5CcC8f19B51c9a";
var web3 = new Web3(Web3.givenProvider);
const contract = new web3.eth.Contract(abi.default, contractAddress);
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
      objectURL: null,
      listNFTs: [],
      nftJSON: {
        image: "",
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
      const reader = new FileReader();
      this.objectURL = URL.createObjectURL(e);
    },
    async createNFT() {
      this.overlay = true;
      var ctx = this;
      const FormData = require("form-data");

      let data = new FormData();
      data.append("file", this.single);

      const url = `https://api.pinata.cloud/pinning/pinFileToIPFS`;
      var userAccount = web3.currentProvider.selectedAddress;
      try {
        await this.$axios
          .$post(url, data, {
            headers: {
              "Content-Type": `multipart/form-data; boundary= ${data._boundary}`,
              pinata_api_key: "7b0392130ef9442078a4",
              pinata_secret_api_key:
                "c5c08101c07d0bba2acd52c49ce5448512b081b5414e67456a7f766776668df4",
            },
          })
          .then(function (response) {
            console.log(response);
            ctx.nftJSON.image = `ipfs://${response.IpfsHash}`;
          })
          .catch(function (error) {
            console.log(error);
          });
        let doc = JSON.stringify(this.nftJSON);
        await window.ethereum.request({ method: "eth_requestAccounts" });
        console.log(doc);
        let res = await contract.methods
          .multiple(userAccount, doc, this.quantity, this.nftJSON.royalty)
          .send({ from: userAccount });
        console.log(res);
        this.overlay = false;
        alert("NFT creado , you trasnsaction hash is: " + res.transactionHash);
      } catch (error) {
        this.overlay = false;
        alert(error);
        console.log(error);
      }
    },
    async showNFTs() {
      var userAccount = web3.currentProvider.selectedAddress;
      let res = await contract.methods.contracts().call({ from: userAccount });
      for (let i = 1; i <= res; i++) {
        let res = await contract.methods
          .tokenURI(i)
          .call({ from: userAccount });
        
        this.listNFTs.push(JSON.parse(res));
      }
    },
  },
};
</script>

<style>
</style>
