# syntax=docker/dockerfile:1
# [3] Parallelism
#FROM golang:1.20-alpine
# [3] Add
# [7] FROM golang:1.20-alpine AS base
# [3]

# [7] Build specific versions with {ARGUMENTS}
ARG GO_VERSION=1.20
FROM golang:${GO_VERSION}-alpine AS base
# [7]
WORKDIR /src

# [1] COPY . . 
# [1] Add below
# [6] COPY go.mod go.sum .
# [1]

# [5] RUN go mod download 
RUN --mount=type=cache,target=/go/pkg/mod/ \
# [5]
# [6]
    --mount=type=bind,source=go.sum,target=go.sum \
    --mount=type=bind,source=go.mod,target=go.mod \
		# [6]
# [5]
    go mod download -x
# [5]

# [1] Add below
# [6] COPY . . 
# [1]

# [3] Add client
FROM base AS build-client
# [3]

# [5] RUN go build -o /bin/client ./cmd/client
RUN --mount=type=cache,target=/go/pkg/mod/ \
# [6]
    --mount=type=bind,target=. \
		# [6]
    go build -o /bin/client ./cmd/client
# [5]

# [3] Add
FROM base AS build-server
# [3]
# [5] RUN go build -o /bin/server ./cmd/server
# [5]
RUN --mount=type=cache,target=/go/pkg/mod/ \
# [6]
    --mount=type=bind,target=. \
		# [6]
    go build -o /bin/server ./cmd/server
# [5]


# [2] Add scratch as NEW STAGES -- disting last "FROM"
# [2] Add below
# [3] FROM scratch

# [3] COPY --from=0 /bin/client /bin/server /bin/
# [2]

# [3] Add
# [4] COPY --from=build-client /bin/client /bin/
# [4] COPY --from=build-server /bin/server /bin/
# [4] ENTRYPOINT [ "/bin/server" ]
# [3]

# [4] Add as individual
FROM scratch AS client
COPY --from=build-client /bin/client /bin/
ENTRYPOINT [ "/bin/client" ]

FROM scratch AS server
COPY --from=build-server /bin/server /bin/
ENTRYPOINT [ "/bin/server" ]
# [4]


 	
