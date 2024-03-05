export default {
  rule: {
    nameRule:
      "* Must be a string of 2-20 characters including letters, numbers, and _ - (hyphen and underscore) without consecutive occurrences of - or _",
  },
  models: {
    title: "Models",
    placeholder: "Models name",
    newModel: {
      title: "Create Model Repository",
      titleDesc: "The repository contains all model files and revision history",
      owner: "Owner",
      modelName: "Model Name",
      modelNickName: "Model Nickname",
      modelDesc: "Model Description",
      public: "Public",
      publicDesc:
        "Anyone on the internet can see this repository. Only you (individual) or members of your organization can contribute.",
      private: "Private",
      privateDesc:
        "Only you (individual) or members of your organization can see and contribute to this repository.",
      tips: "After creating the model, you can upload your files using the web or Git.",
      createModel: "Create Model",
    },
  },
  datasets: {
    title: "Datasets",
    placeholder: "Datasets name",
    newDataset: {
      title: "Create New Dataset Repository",
      titleDesc:
        "The repository contains all model files and revision history.",
      owner: "Owner",
      datasetName: "Dataset Name",
      datasetNickName: "Dataset Nickname",
      datasetDesc: "Dataset Description",
      public: "Public",
      publicDesc:
        "Anyone on the internet can see this repository. Only you (individual) or members of your organization can commit.",
      private: "Private",
      privateDesc:
        "Only you (individual) or members of your organization can view and commit to this repository.",
      tips: "After creating the model, you can use the web or Git to upload your files.",
      tips2:
        "Creating public datasets is currently not supported. Please contact the administrator for manual review if needed.",
      createDataset: "Create Dataset",
    },
  },
  navbar: {
    models: "Models",
    datasets: "Datasets",
    profile: "Profile",
    editProfile: "Account Settings",
    newModel: "New Model",
    newDataset: "New Dataset",
    newOrganization: "New Organization",
    logout: "Logout",
    loginRegister: "Login/Registe",
    login: "Login",
  },
  all: {
    confirm: "Confirm",
    cancel: "Cancel",
    recentlyUpdate: "Recently Update",
    trending: "Trending",
    mostDownload: "Most Download",
    mostFavorite: "Most Favorite",
    noData: "No Data",
    save: "Save",
    inputNickNamePlc: "Enter nickname",
    inputDescPlc: "Enter description",
  },
  community: {
    discussion: {
      back: "Back to topic list",
      new: "New topic",
    },
    discussionDetail: {
      reply: "Reply",
      comment: "Comment",
      cancel: "Cancel",
      updateSuccess: "Title update successful!",
      warn: "Content cannot be empty",
      addSuccess: "Add comment successfully",
    },
    MD: {
      edit: "Edit",
      preview: "Preview",
      desc: "Upload pictures, audio, video, or by dragging and dropping ",
      click: "Click here to upload",
      default: "Leave a comment",
    },
    newDiscussion: {
      new: "New topic",
      title: "Title",
      content: "Content",
      create: "Create a topic",
      cancel: "Cancel",
    },
    empty: {
      wellcome: "Welcome to discuss ",
      decs: "This is the place to discuss and collaborate with OpenCSG!",
      new: "New topic ",
    },
  },
  profile: {
    editProfile: "Edit Profile",
    settings: "Settings",
    interests: "Interests",
    organization: "Organization",
    menu: {
      profile: "Profile",
      accountInformation: "Account Information",
      accessToken: "Access Token",
      gitToken: "Git Token",
      sshKey: "SSH Keys",
      billing: "Billing",
    },
    edit: {
      title: "Profile Edit",
      uploadAvatar: "Upload Avatar",
      removeAvatar: "Remove Avatar",
      username: "Username,",
      nickName: "Nickname",
      phone: "Phone Number",
      email: "Email",
    },
  },
};
