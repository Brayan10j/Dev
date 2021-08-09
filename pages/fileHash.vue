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
        <br />
        {{ registroJSON.hashFile }}
        
      </v-card-text>

      <v-card-actions>
        <v-btn v-show="resgister" color="blue" text @click="dialogCreateRegistro = true" > Register </v-btn>
      </v-card-actions>
    </v-card>
    <v-dialog v-model="dialogCreateRegistro" persistent max-width="900px">
      <v-overlay :value="overlay">
        <v-progress-circular indeterminate size="150"></v-progress-circular>
      </v-overlay>
      <v-card>
        <v-card-title>
          <span class="text-h5">Registration</span>
        </v-card-title>
        <v-card-text>
          <v-container>
            <v-row>
              <v-col>
                <v-col cols="12">
                  <v-text-field
                    label="Name"
                    v-model="registroJSON.name"
                    required
                  ></v-text-field>
                </v-col>
                <v-col cols="12">
                  <v-text-field
                    label="Last Name"
                    v-model="registroJSON.lastName"
                    required
                  ></v-text-field>
                </v-col>
                <v-col cols="12">
                  <v-text-field
                    label="Age"
                    v-model="registroJSON.age"
                    required
                  ></v-text-field>
                </v-col>
                <v-col cols="12">
                  <v-text-field
                    label="Nacionality"
                    v-model="registroJSON.nacionality"
                    required
                  ></v-text-field>
                </v-col>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="blue darken-1" text @click="dialogCreateRegistro = false">
            Close
          </v-btn>
          <v-btn color="blue darken-1" text > Save </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>


<script>
export default {
  data() {
    return {
      dialogCreateRegistro : false,
      hashFile: "",
      overlay: false,
      resgister: false,
      registroJSON: {
        name : "",
        lastName : "",
        age : "",
        nacionality: "",
        hashFile: ""
      }
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
        this.registroJSON.hashFile = res.responsive
        this.resgister = true
      } catch (error) {
        this.resgister = false
        console.log(error.message);
      }
    },
  },
};
</script>

<style>
</style>