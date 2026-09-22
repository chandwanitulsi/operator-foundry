FROM registry.access.redhat.com/ubi9/go-toolset:1.26 AS builder

USER root

WORKDIR /build

# Cache module downloads separately from source changes
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o operator-foundry ./cmd/operator-foundry

## Final image

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest@sha256:8ebe2ad8fdf3cab3e5a53c1edc69194c98209cfadab24b884f4ad9ebcf7bbbfc

LABEL \
  name="operator-foundry" \
  com.redhat.component="konflux-operator-foundry" \
  description="CLI for Konflux operator pipeline tasks" \
  io.k8s.description="CLI for Konflux operator pipeline tasks" \
  io.k8s.display-name="operator-foundry" \
  summary="Konflux operator pipeline task CLI" \
  io.openshift.tags="konflux,operator,olm,fbc"

COPY --from=builder /build/operator-foundry /usr/local/bin/operator-foundry
COPY LICENSE /licenses/LICENSE

# OpenShift preflight and Tekton task compatibility
USER 1001

ENTRYPOINT ["/usr/local/bin/operator-foundry"]
