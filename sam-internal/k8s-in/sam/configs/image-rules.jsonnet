{
  image_rules: [
    {
      match: "^(ops0-artifactrepo1-0-prd.data.sfdc.net)",
      image_check_replacement_host: "",
      err_msg: "",
    },
    {
      match: "^(ops0-artifactrepo2-0-prd.data.sfdc.net)",
      image_check_replacement_host: "",
      err_msg: "",
    },
    {
      match: "^(gcr.io)",
      image_check_replacement_host: "",
      err_msg: "",
      skip_image_exist_check: true,
    },
    {
      match: "^(ops0-artifactrepo2-0-xrd.(?:slb|data).sfdc.net)",
      image_check_replacement_host: "ops0-artifactrepo1-0-prd.data.sfdc.net",
      err_msg: "",
    },
    {
      match: "^(ops0-artifactrepo1-0-([a-z0-9]{3}).(?:slb|data).sfdc.net)",
      image_check_replacement_host: "ops0-artifactrepo2-0-prd.data.sfdc.net",
      err_msg: "",
    },
    {
      match: "^(dva|tnrp|docker-all|sfci)",
      image_check_replacement_host: "ops0-artifactrepo2-0-prd.data.sfdc.net",
      is_short_form: true,
      err_msg: "",
    },
    {
      match: "^(minikube)",
      image_check_replacement_host: "",
      err_msg: "",
      skip_image_exist_check: true,
    },
    {
      match: "^[a-zA-Z0-9-./:]",
      image_check_replacement_host: "",
      err_msg: "This is not a valid image input, skip checking ...",
    },
  ],
}
