FROM node:23-alpine AS base

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="${PATH}:${PNPM_HOME}"

RUN npm install --global pnpm@latest

WORKDIR /app

FROM base AS builder

COPY . .

RUN pnpm install

RUN pnpm build

FROM base AS installer

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="${PATH}:${PNPM_HOME}"

RUN npm install --global pnpm@latest 

RUN pnpm add -g vinxi

COPY .gitignore .gitignore
# COPY --from=builder /app/out/json/ .
# COPY --from=builder /app/package-lock.json ./package-lock.json
# COPY --from=builder /app/.output .
# COPY --from=builder /app/.vinxi .
# COPY turbo.json turbo.json
COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/.output /app/.output

RUN pnpm install --prod

FROM base AS runner

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="${PATH}:${PNPM_HOME}"

RUN npm install --global pnpm@latest

RUN pnpm add -g vinxi

COPY --from=installer /app/.output /app/.output

EXPOSE 3000

CMD ["sh", "-c", "node .output/server/index.mjs"]
