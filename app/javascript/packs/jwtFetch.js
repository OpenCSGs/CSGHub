import { useCookies } from "vue3-cookies";
const { cookies } = useCookies();

const jwtFetch = async (url, options = {}, forceLogin = false) => {
  const jwtToken = cookies.get('user_token')
  const jwtTokenValid = cookies.get('user_token_valid')
  if (forceLogin && !jwtToken) {
    window.location.href = "/login"
  }
  options.headers = options.headers || {}
  if (jwtToken && jwtTokenValid === 'true') {
    options.headers = { "Authorization": `Bearer ${jwtToken}`, ...options.headers };
  }

  response = await fetch(url, options)

  if (!response.ok) {
    response.json().then((error) => {
      fetchErrorEvents()
      ElMessage({ message: error.msg, type: 'warning' })
    })
  }

  return response
};

const fetchErrorEvents = async () => {
  console.log(navigator.userAgent);
  const params = {
    ext: {"username":"test_user_name_1","agent":{navigator.userAgent}},
    id: "web_server_err",
    m: "error",
    v: "error msg get from hub api server"
  }
  const options = {
    method: 'POST',
    headers: { "Authorization": `Bearer ${jwtToken}`, ...options.headers },
    body: JSON.stringify(params)
  }

  response = await fetch(`${csghubServer}/api/v1/events`, options)
  if (!response.ok) {
    response.json().then((error) => {
      ElMessage({ message: error.msg, type: 'warning' })
    })
  }
}

export default jwtFetch;