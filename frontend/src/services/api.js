import axios from "axios"

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || "http://localhost:3000/api/v1",
  timeout: 15000,
  headers: {
    "Content-Type": "application/json",
  },
})

api.interceptors.response.use(
  (response) => response,
  (error) => {
    const message =
      error.response?.data?.message ||
      error.response?.data?.details?.map((d) => d.message).join(", ") ||
      "Erro inesperado. Tente novamente."

    const enhancedError = new Error(message)
    enhancedError.status = error.response?.status
    enhancedError.code = error.response?.data?.code
    enhancedError.details = error.response?.data?.details
    return Promise.reject(enhancedError)
  },
)

export default api
