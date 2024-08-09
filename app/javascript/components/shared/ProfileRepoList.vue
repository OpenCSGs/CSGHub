<template>
  <div class="sm:w-[100%] sm:mt-[36px]">
    <!-- collections -->
    <div>
      <h3 class="text-[20px] text-[#303133] flex items-center gap-[8px]">
        <SvgIcon name="collections" width="18" height="18" />
        <span>{{ $t("collections.collection") }}</span>
      </h3>
      <div v-if="hasCollections" class="mb-4 mt-[16px]">
        <CollectionCards 
          v-if="collections.data.length > 0" 
          :collections="collections.data"
        />
      </div>
      <div v-else class="flex flex-wrap gap-4 mb-4 mt-[16px]">
        {{ $t("all.noData") }}
      </div>
      <view-more v-if="collections.more" target="collections" @view-more-targets="viewMoreTargets"></view-more>
      <el-skeleton class="pr-6" v-if="collectionsLoading" :rows="2" animated />
    </div>

    <!-- models -->
    <div>
      <h3 class="text-[20px] text-[#344054] flex items-center gap-[8px]">
        <SvgIcon name="models" width="18" height="18" />
        <span>{{ $t("organization.model") }}</span>
      </h3>
      <div v-if="hasModels" class="grid grid-cols-2 xl:grid-cols-1 gap-4 mb-4 mt-[16px]">
        <repo-item v-for="model in models.data" :repo="model" repo-type="model"></repo-item>
      </div>
      <div v-else class="flex flex-wrap gap-4 mb-4 mt-[16px]">
        {{ $t("all.noData") }}
      </div>
      <view-more v-if="models.more" target="models" @view-more-targets="viewMoreTargets"></view-more>
      <el-skeleton class="pr-6" v-if="modelsLoading" :rows="2" animated />
    </div>

    <!-- datasets -->
    <div class="mt-[32px]">
      <h3 class="text-[20px] text-[#344054] flex items-center gap-[8px]">
        <SvgIcon name="datasets" width="18" height="18" />
        <span>{{ $t("organization.dataset") }}</span>
      </h3>
      <div v-if="hasDatasets" class="grid grid-cols-2 xl:grid-cols-1 gap-4 mb-4 mt-[16px]">
        <repo-item v-for="dataset in datasets.data" :repo="dataset" repo-type="dataset"></repo-item>
      </div>
      <div v-else class="flex flex-wrap gap-4 mb-4 mt-[16px]">
        {{ $t("all.noData") }}
      </div>
      <view-more
        v-if="datasets.more"
        target="datasets"
        @view-more-targets="viewMoreTargets"
      ></view-more>
      <el-skeleton class="pr-6" v-if="datasetsLoading" :rows="2" animated />
    </div>

    <!-- code repo -->
    <div class="mt-[32px]">
      <h3 class="text-[20px] text-[#344054] flex items-center gap-[8px]">
        <SvgIcon name="codes" width="18" height="18" />
        <span>{{ $t("organization.code") }}</span>
      </h3>
      <div v-if="hasCodes" class="grid grid-cols-2 xl:grid-cols-1 gap-4 mb-4 mt-[16px]">
        <repo-item v-for="code in codes.data" :repo="code" repo-type="code"></repo-item>
      </div>
      <div v-else class="flex flex-wrap gap-4 mb-4 mt-[16px]">
        {{ $t("all.noData") }}
      </div>
      <view-more v-if="codes.more" target="codes" @view-more-targets="viewMoreTargets"></view-more>
      <el-skeleton class="pr-6" v-if="codeLoading" :rows="2" animated />
    </div>

    <!-- spaces -->
    <div class="mt-[32px]">
      <h3 class="text-[20px] text-[#344054] flex items-center gap-[8px]">
        <SvgIcon name="spaces" width="18" height="18" />
        <span>{{ $t("organization.space") }}</span>
      </h3>
      <div v-if="hasSpaces" class="grid grid-cols-2 xl:grid-cols-1 gap-4 mb-4 mt-[16px]">
        <application-space-item v-for="repo in spaces.data" :repo="repo" repo-type="space" />
      </div>
      <div v-else class="flex flex-wrap gap-4 mb-4 mt-[16px]">
        {{ $t("all.noData") }}
      </div>
      <view-more v-if="spaces.more" target="spaces" @view-more-targets="viewMoreTargets"></view-more>
      <el-skeleton class="pr-6" v-if="spacesLoading" :rows="2" animated />
    </div>

    <!-- endpoints -->
    <div v-if="hasEndpoints" class="mt-[32px]">
      <h3 class="text-[20px] text-[#344054] flex items-center gap-[8px]">
        <SvgIcon name="endpoint" width="18" height="18" />
        <span>{{ $t("endpoints.title") }}</span>
      </h3>
      <div v-if="hasEndpoints" class="grid grid-cols-2 lg:grid-cols-1 gap-4 mb-4 mt-[16px]">
        <EndpointItem v-for="endpoint in endpoints.data" :endpoint="endpoint" :namespace="name" />
      </div>
      <div v-else class="flex flex-wrap gap-4 mb-4 mt-[16px]">
        {{ $t("all.noData") }}
      </div>
      <view-more
        v-if="endpoints.more"
        target="endpoints"
        @view-more-targets="viewMoreTargets"
      ></view-more>
      <el-skeleton class="pr-6" v-if="endpointsLoading" :rows="2" animated />
    </div>

    <!-- finetunes -->
    <div v-if="isCurrentUser" class="mt-[32px]">
      <h3 class="text-[20px] text-[#344054] flex items-center gap-[8px]">
        <SvgIcon name="profile_finetune" width="18" height="18" />
        <span>{{ $t("finetune.title") }}</span>
      </h3>
      <div v-if="hasFinetune" class="grid grid-cols-2 xl:grid-cols-1 gap-4 mb-4 mt-[16px]">
        <FinetuneItem v-for="finetune in finetunes.data" :repo="finetune" repo-type="finetune" />
      </div>
      <div v-else class="flex flex-wrap gap-4 mb-4 mt-[16px]">
        {{ $t("all.noData") }}
      </div>
      <view-more v-if="finetunes.more" target="finetunes" @view-more-targets="viewMoreTargets"></view-more>
      <el-skeleton class="pr-6" v-if="finetunesLoading" :rows="2" animated />
    </div>
  </div>
</template>

<script setup>
  import { computed, ref, onMounted, inject } from "vue"
  import RepoItem from "./RepoItem.vue"
  import CollectionCards from "../collections/CollectionCards.vue"
  import FinetuneItem from "./FinetuneItem.vue"
  import ApplicationSpaceItem from "../application_spaces/ApplicationSpaceItem.vue"
  import EndpointItem from "../endpoints/EndpointItem.vue"
  import ViewMore from "./ViewMore.vue"
  import { useI18n } from "vue-i18n"
  import jwtFetch from "../../packs/jwtFetch"
  import { ElMessage } from "element-plus"
  import { useCookies } from 'vue3-cookies'
  const { cookies } = useCookies()
  const props = defineProps({
    name: String,
    initiator: String
  })

  const { t } = useI18n()
  const current_user = cookies.get('current_user')
  const isCurrentUser = computed(() => {
    return props.name === current_user
  })

  const collections = ref([])
  const models = ref([])
  const datasets = ref([])
  const codes = ref([])
  const spaces = ref([])
  const endpoints = ref([])
  const finetunes = ref([])
  const collectionsLoading = ref(false)
  const modelsLoading = ref(false)
  const datasetsLoading = ref(false)
  const codeLoading = ref(false)
  const spacesLoading = ref(false)
  const endpointsLoading = ref(false)
  const finetunesLoading = ref(false)

  const hasCollections = computed(() => collections.value?.total > 0)
  const hasModels = computed(() => models.value?.total > 0)
  const hasDatasets = computed(() => datasets.value?.total > 0)
  const hasCodes = computed(() => codes.value?.total > 0)
  const hasSpaces = computed(() => spaces.value?.total > 0)
  const hasEndpoints = computed(() => endpoints.value?.total > 0)
  const hasFinetune = computed(() => finetunes.value?.total > 0)

  const prefixPath =
    document.location.pathname.split("/")[1] === "organizations" ? "organization" : "user"
  const csghubServer = inject("csghubServer")

  const getProfileRepoData = async () =>{
    const defaultTotal = 6
    const collectionsUrl = reposUrl("collections")
    const modelsUrl = reposUrl("models")
    const datasetsUrl = reposUrl("datasets")
    const spacesUrl = reposUrl("spaces")
    const codesUrl = reposUrl("codes")
    const promises = [
        fetchData(collectionsUrl, collections, defaultTotal),
        fetchData(modelsUrl, models, defaultTotal),
        fetchData(datasetsUrl, datasets, defaultTotal),
        fetchData(spacesUrl, spaces, defaultTotal),
        fetchData(codesUrl, codes, defaultTotal)
    ];
    if(props.initiator=='profile'){
      if(isCurrentUser.value){
        const endpointsUrl = reposUrl("endpoints")
        promises.push(fetchData(endpointsUrl, endpoints, defaultTotal, 'endpoints'));
        const finetunesUrl = reposUrl("finetunes")
        promises.push(fetchData(finetunesUrl, finetunes, defaultTotal));  
      }
    }
    await Promise.all(promises);
  }

  const viewMoreTargets = (target) => {
    if (target === "models") {
      modelsLoading.value = true
      fetchMoreModels()
    } else if (target === "datasets") {
      datasetsLoading.value = true
      fetchMoreDatasets()
    } else if (target === "spaces") {
      spacesLoading.value = true
      fetchMoreSpaces()
    } else if (target === "codes") {
      codeLoading.value = true
      fetchMoreCodes()
    } else if (target === "endpoints") {
      endpointsLoading.value = true
      fetchMoreEndpoints()
    } else if (target === "collections") {
      collectionsLoading.value = true
      fetchMoreCollections()
    }
  }

  const reposUrl = (type) => {
    switch (props.initiator) {
      case "likes":
        return `${csghubServer}/api/v1/${prefixPath}/${props.name}/likes/${type}`
      case "profile":
      default:
        if (type === "endpoints") {
          return `${csghubServer}/api/v1/${prefixPath}/${props.name}/run/model`
        } else if (type === "finetunes") {
          return `${csghubServer}/api/v1/${prefixPath}/${props.name}/finetune/instances`
        } else {
          return `${csghubServer}/api/v1/${prefixPath}/${props.name}/${type}`
        }
    }
  }

  const fetchMoreCollections = async () => {
    const url = reposUrl("collections")
    await fetchData(url, collections, collections.value.total)
  }
  const fetchMoreModels = async () => {
    const url = reposUrl("models")
    await fetchData(url, models, models.value.total)
  }

  const fetchMoreDatasets = async () => {
    const url = reposUrl("datasets")
    await fetchData(url, datasets, datasets.value.total)
  }

  const fetchMoreSpaces = async () => {
    const url = reposUrl("spaces")
    await fetchData(url, spaces, spaces.value.total)
  }

  const fetchMoreCodes = async () => {
    const url = reposUrl("codes")
    await fetchData(url, codes, codes.value.total)
  }

  const fetchMoreEndpoints = async () => {
    const url = reposUrl("endpoints")
    await fetchData(url, endpoints, endpoints.value.total, 'endpoints')
  }

  const fetchData = async (url, targetRef, total, type) => {
    const params = new URLSearchParams()
    params.append("per", total)
    params.append("page", 1)
    if(type=='endpoints'){
      params.append("deploy_type", 1)
    }

    jwtFetch(`${url}?${params}`)
      .then((response) => {
        if (!response.ok) {
          ElMessage({
            message: t("all.loadError"),
            type: "warning"
          })
        } else {
          response.json().then((data) => {
            targetRef.value = data
            if(targetRef.value?.total > 6 && total === 6){
              targetRef.value.more = true
            }else if(total > 6){
              targetRef.value.more = false
            }
          })
        }
      })
      .catch((error) => {
        console.error(error)
      })
      .finally(() => {
        if (targetRef === models) {
          modelsLoading.value = false
        } else if (targetRef === datasets) {
          datasetsLoading.value = false
        } else if (targetRef === codes) {
          codeLoading.value = false
        } else if (targetRef === spaces) {
          spacesLoading.value = false
        } else if (targetRef === endpoints) {
          endpointsLoading.value = false
        }
      })
  }

  onMounted(() => {
    getProfileRepoData()
  })
</script>
