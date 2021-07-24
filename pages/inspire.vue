<template>
  <v-container>
    <v-btn
            fab
            dark
            fixed
            bottom
            right
            color="blue"
            @click="dialogCreateNFT = true"
              >
                <v-icon>mdi-plus</v-icon>
              </v-btn>
    <v-container>
      <v-row>
        <v-col cols="6">
          <v-img src="./nft.png"></v-img>
        </v-col>
        <v-col cols="6">
          <h1 class="font-italic" style="text-align: center">
            NFT Showroom is a digital art marketplace built on Hive, a fast and
            free blockchain that makes creating and collecting rare digital art
            simple and accessible!
          </h1>
          <br>
          <v-carousel :show-arrows="false">
            <v-carousel-item
              v-for="(item, i) in listNFTs.slice((listNFTs.length - 3),listNFTs.length)"
              :key="i"
              :src="item.image"
            ></v-carousel-item>
          </v-carousel>
        </v-col>
      </v-row>
    </v-container>
    <br />
    <h1>NFTs Tokenized</h1>
    <br />
    <v-row>
      <v-col v-for="(item, index) in listNFTs" :key="index">
        <v-card
          class="mx-auto"
          width="400"
          height="600"
          @click.stop="showNFT(item)"
        >
          <v-img :src="item.image"></v-img>
          <v-card-title>{{ item.name }}</v-card-title>
          <v-card-subtitle>
            {{ item.nameAuthor }}
          </v-card-subtitle>
          <v-card-actions>
            <v-btn
              color="blue darken-1"
              text
              :href="item.image"
              target="_blank"
            >
              Ver en IPFS
            </v-btn>
            <v-spacer></v-spacer>
            <v-card-title>{{ item.price }} (ETH)</v-card-title>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
    <v-dialog v-model="dialogNFT" max-width="800px">
      <v-card width="800px" class="mt-4">
        <v-card-text>
          <v-row>
            <v-col cols="4">
              <v-card-title> Name </v-card-title>
              <v-card-subtitle> {{ NFT.name }} </v-card-subtitle>
              <v-card-title> Author </v-card-title>
              <v-card-subtitle> {{ NFT.nameAuthor }} </v-card-subtitle>
              <v-card-title> Description </v-card-title>
              <v-card-subtitle>{{ NFT.description }} </v-card-subtitle>
              <v-card-actions>
                <v-btn color="blue darken-1" bottom> Buy Now </v-btn>
              </v-card-actions>
            </v-col>
            <v-col cols="8">
              <v-card class="mx-auto">
                <v-img :src="NFT.image" width="500px"></v-img>
              </v-card>
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-dialog>
    <v-dialog v-model="dialogCreateNFT" persistent max-width="900px">
      <v-overlay :value="overlay">
        <v-progress-circular indeterminate size="150"></v-progress-circular>
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
      show: false,
      overlay: false,
      singleNFT: false,
      multipleNFT: false,
      single: null,
      singleBuffer: null,
      multiple: null,
      NFT: {},
      dialogNFT: false,
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
        description: "",
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
    showNFT(item) {
      this.dialogNFT = true;
      this.NFT = item;
    },
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
            ctx.nftJSON.image = `https://gateway.pinata.cloud/ipfs/${response.IpfsHash}`; // https://gateway.pinata.cloud/ipfs/
          })
          .catch(function (error) {
            console.log(error);
          });
        let doc = JSON.stringify(this.nftJSON);
        await window.ethereum.request({ method: "eth_requestAccounts" });
        let res = await contract.methods
          .multiple(userAccount, doc, this.quantity, this.nftJSON.royalty)
          .send({ from: userAccount });
        console.log(res);
        this.overlay = false;
        this.dialogCreateNFT = false;
        alert("NFT creado , you trasnsaction hash is: " + res.transactionHash);
      } catch (error) {
        this.overlay = false;
        alert(error);
        console.log(error);
      }
    },
    async showNFTs() {
      this.listNFTs = [];
      var userAccount = web3.currentProvider.selectedAddress;
      let res = await contract.methods.contracts().call({ from: userAccount });
      for (let i = 1; i <= res; i++) {
        let res = await contract.methods
          .tokenURI(i)
          .call({ from: userAccount });
        try {
          this.listNFTs.push(JSON.parse(res));
        } catch (error) {}
      }
    },
  },
  mounted() {
    this.showNFTs();
  },
};
</script>

<style>
</style>
