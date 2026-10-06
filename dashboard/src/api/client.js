import axios from "axios";

const api = axios.create({ baseURL: "https://trimming-send-vividness.ngrok-free.dev/api" });

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export default api;
