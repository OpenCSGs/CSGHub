<template>
  <div class="w-full bg-[#FAFCFF] pt-9 pb-[60px] xl:px-10 md:px-0 md:pb-6 md:h-auto border-b border-[#EBEEF5]">
    <div class="mx-auto max-w-[1280px]">
      <repo-header
        :private="model.data.private"
        :license="model.data.license"
        :name="model.data.name"
        :nickname="model.data.nickname"
        :desc="model.data.description"
        :path="model.data.path"
        :tags="tags"
        :avatar="avatar"
        :owner-url="ownerUrl"
        repo-type="model"
      />
    </div>
  </div>
  <div class="mx-auto max-w-[1280px] mt-[-40px] xl:px-10 md:px-0">
    <repo-tabs
      :blob="blob.data"
      :local-repo-id="localRepoId"
      :repo-detail="model.data"
      :last-commit="lastCommit.data"
      :branches="branches.data"
      :current-branch="currentBranch"
      :current-path="currentPath"
      :default-tab="defaultTab"
      :actionName="actionName"
      :settingsVisibility="settingsVisibility"
      :can-write="canWrite"
      :tags="tags"
      :tag-list="tagList"
      repo-type="model"
    />
  </div>
</template>

<script setup>
import RepoHeader from '../shared/RepoHeader.vue'
import RepoTabs from '../shared/RepoTabs.vue'

const props = defineProps({
  localRepoId: String,
  defaultTab: String,
  model: Object,
  tagList: Object,
  localModel: Object,
  lastCommit: Object,
  branches: Object,
  tags: Object,
  currentBranch: String,
  currentPath: String,
  blob: Object,
  actionName: String,
  settingsVisibility: Boolean,
  avatar: String,
  ownerUrl: String,
  canWrite: Boolean
})
</script>
<style scoped>
  body {
    background: #fff !important;
  }
</style>
