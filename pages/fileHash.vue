<template>
  <v-container>
    <v-overlay :value="overlay">
        <v-progress-circular indeterminate size="150"></v-progress-circular>
      </v-overlay>
    <v-card class="mx-auto" max-width="600">
    <v-card-title>Hash File</v-card-title>

    <v-card-text class="text--primary">
      <v-file-input label="File input" @change="getFile"></v-file-input>
      Your file has is : 
      <br/>
      <v-btn color="blue" text :href="`https://ipfs.io/ipfs/${hashFile}`" target="_blank"> {{ hashFile }} </v-btn>
      
    </v-card-text>

    <v-card-actions>
      <v-btn color="blue" text> Register </v-btn>
    </v-card-actions>
  </v-card>
  </v-container>
  
</template>


<script>
export default {
  data() {
    return {
      hashFile: "",
      overlay: false,
    };
  },
  methods: {
    getFile(e) {
      this.getHash(e);
    },
    async getHash(file) {
      this.overlay = true;
      var ctx = this;
      const FormData = require("form-data");
      let data = new FormData();
      data.append("file", file);
      const url = `https://api.pinata.cloud/pinning/pinFileToIPFS`;
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
            ctx.hashFile = response.IpfsHash;
          });
        this.overlay = false;
      } catch (error) {
        alert(error.message);
        this.overlay = false;
      }
    },
  },
};
</script>

<style>
</style>