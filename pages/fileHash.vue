<template>
  <v-container>
    <v-overlay :value="overlay">
      <v-progress-circular indeterminate size="150"></v-progress-circular>
    </v-overlay>
    <v-card class="mx-auto" max-width="800">
      <v-card-title>Hash File</v-card-title>

      <v-card-text class="text--primary">
        <v-file-input label="File input" @change="getFile"></v-file-input>
        Your file has is :
        <br />
        <v-btn
          color="blue"
          text
          :href="`https://ipfs.io/ipfs/${hashFile}`"
          target="_blank"
        >
          {{ hashFile }}
        </v-btn>
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
      try {
        let formData = new FormData();

        formData.append("file", file);
        let res = await this.$axios.$post("/hashFile", formData, {
          headers: {
            "Content-Type": "multipart/form-data",
          },
        });
        console.log(res)
        this.hashFile = res.responsive
      } catch (error) {
        console.log(error.message);
      }
    },
  },
};
</script>

<style>
</style>