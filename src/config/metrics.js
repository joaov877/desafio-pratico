const client = require("prom-client")

const register = new client.Registry()

client.collectDefaultMetrics({ register })

const httpRequestsTotal = new client.Counter({
  name: "http_requests_total",
  help: "Total de requisições HTTP recebidas",
  labelNames: ["method", "route", "status_code"],
  registers: [register],
})

const httpRequestDurationSeconds = new client.Histogram({
  name: "http_request_duration_seconds",
  help: "Tempo de resposta das requisições HTTP em segundos",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.01, 0.05, 0.1, 0.3, 0.5, 1, 2, 5],
  registers: [register],
})

const metricsMiddleware = (req, res, next) => {
  if (req.path === "/metrics") {
    return next()
  }

  const start = process.hrtime.bigint()

  res.on("finish", () => {
    const end = process.hrtime.bigint()
    const duration = Number(end - start) / 1_000_000_000

    const route = req.route
      ? `${req.baseUrl || ""}${req.route.path}`
      : "unmatched"

    const labels = {
      method: req.method,
      route,
      status_code: String(res.statusCode),
    }

    httpRequestsTotal.inc(labels)
    httpRequestDurationSeconds.observe(labels, duration)
  })

  next()
}

module.exports = {
  register,
  metricsMiddleware,
}
