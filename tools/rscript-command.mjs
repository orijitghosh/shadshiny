export function resolveRscript(env = process.env) {
  return env.SHADSHINY_RSCRIPT || "Rscript";
}
