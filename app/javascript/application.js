import "trix"
import "@rails/actiontext"
import refreshJWT from "./packs/refreshJWT.js"

refreshJWT()

// Vue config
import { createApp } from "vue/dist/vue.esm-bundler.js"
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'

import { useCookies } from "vue3-cookies"
import { createI18n } from 'vue-i18n'
import en from '../../config/locales/en.js'
import zh from '../../config/locales/zh.js'

import Navbar from "./components/navbar/NewNavbar.vue"
import SpaceIntro from "./components/spaces/SpaceIntro.vue"
import SpaceCard from "./components/spaces/SpaceCard.vue"
import SpaceCards from "./components/spaces/SpaceCards.vue"
import LogoutFooter from "./components/footer/LogoutFooter.vue"
import LoginFooter from "./components/footer/LoginFooter.vue"
import CommentList from "./components/comment/CommentList.vue"
import ExpertCard from "./components/ExpertCard.vue"
import PartnerCard from "./components/PartnerCard.vue"
import DatasetCard from "./components/DatasetCard.vue"
import ModelDetail from "./components/models/ModelDetail.vue"
import DatasetDetail from "./components/datasets/DatasetDetail.vue"
import ModelCard from "./components/ModelCard.vue"
import ExpertForm from "./components/form/ExpertForm.vue"
import PartnerForm from "./components/form/PartnerForm.vue"
import CampaignCard from "./components/campaigns/CampaignCard.vue"
import CampaignCards from "./components/campaigns/CampaignCards.vue"
import ApplicationSpaceDetail from "./components/application_spaces/ApplicationSpaceDetail.vue"
import Profile from "./components/user_settings/Profile.vue"
import ProfileEdit from "./components/user_settings/ProfileEdit.vue"
import ProfileSettings from "./components/user_settings/ProfileSettings.vue"
import NewOrganization from "./components/organizations/NewOrganization.vue"
import GitTokenSettings from "./components/user_settings/GitTokenSettings.vue"
import SshKeySettings from "./components/user_settings/SshKeySettings.vue"
import NewModel from "./components/models/NewModel.vue"
import TagSidebar from "./components/tags/TagSidebar.vue"
import NewDataset from "./components/datasets/NewDataset.vue"
import OrganizationSettings from "./components/organizations/OrganizationSettings.vue"
import OrganizationDetail from "./components/organizations/OrganizationDetail.vue"
import SolutionPage from "./components/solution/SolutionPage.vue"
import ProductPage from "./components/product/ProductPage.vue"
import Hero from "./components/about/Hero.vue"
import Company from "./components/about/Company.vue"
import OnPremiseFooter from "./components/footer/OnPremiseFooter.vue"
import ComputingPage from "./components/computing/ComputingPage.vue"
import LandingPage from "./components/landing_page/LandingPage.vue"
import PrivacyPage from "./components/policy/PrivacyPage.vue"
import DailyPaperNew from "./components/daily_paper/New.vue"
import DailyPaperIndex from "./components/daily_paper/Index.vue"
import DailyPaperShow from "./components/daily_paper/Show.vue"
import ProfileRepoList from "./components/shared/ProfileRepoList.vue"
import RepoCards from "./components/shared/RepoCards.vue"
import RepoItem from "./components/shared/RepoItem.vue"
import ApplicationSpaceItem from "./components/application_spaces/ApplicationSpaceItem.vue"
import EkbLanding from "./components/ekb/EkbLanding.vue"
import NewApplicationSpace from "./components/application_spaces/NewApplicationSpace.vue"
import NewCode from "./components/codes/NewCode.vue"
import CodeDetail from "./components/codes/CodeDetail.vue"
import SvgIcon from "./components/shared/SvgIcon.vue"
import LittleMonster from "./components/dialog/LittleMonster.vue"

const pinia = createPinia()

const app = createApp({
  components: {
    Navbar,
    SpaceIntro,
    SpaceCard,
    SpaceCards,
    CommentList,
    DatasetCard,
    DatasetDetail,
    ExpertCard,
    ExpertForm,
    ModelCard,
    ModelDetail,
    PartnerCard,
    PartnerForm,
    LogoutFooter,
    LoginFooter,
    CampaignCard,
    CampaignCards,
    ApplicationSpaceDetail,
    Profile,
    ProfileEdit,
    ProfileSettings,
    GitTokenSettings,
    SshKeySettings,
    NewOrganization,
    NewModel,
    TagSidebar,
    NewDataset,
    OrganizationDetail,
    SolutionPage,
    ProductPage,
    Hero,
    Company,
    OnPremiseFooter,
    ComputingPage,
    LandingPage,
    PrivacyPage,
    OrganizationSettings,
    DailyPaperNew,
    DailyPaperIndex,
    DailyPaperShow,
    ProfileRepoList,
    RepoCards,
    RepoItem,
    ApplicationSpaceItem,
    EkbLanding,
    NewApplicationSpace,
    NewCode,
    CodeDetail,
    LittleMonster
  },
  provide:{
    defaultTags: DEFAULT_TAGS,
    csghubServer: CSGHUB_SERVER,
    nameRule: /^(?=.{2,64}$)(?!.*[-_.]{2})[a-zA-Z][a-zA-Z0-9_.-]*[a-zA-Z0-9]+$/
  }
}).use(ElementPlus, {
  locale: zhCn,
});

const { cookies } = useCookies()
const defaultLanguage = ['zh', 'zh-cn', 'zh-tw'].includes(navigator.language) ? 'zh' : 'en';

const i18n = createI18n({
  legacy: false,
  locale: cookies.get('locale') || defaultLanguage,
  messages: {
    en,
    zh
  }
})

// register Element UI Icons
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}
app.component('SvgIcon', SvgIcon)
app.use(i18n)
app.use(pinia)
app.mount("#app")
