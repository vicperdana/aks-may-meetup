FROM mcr.microsoft.com/dotnet/sdk:6.0 AS builder
ARG TARGETARCH
ARG TARGETOS

RUN arch=$TARGETARCH \
    && if [ "$arch" = "arm64" ]; then arch="x64"; fi \
    && echo $TARGETOS-$arch > /tmp/rid

WORKDIR /source

# caches restore result by copying csproj file separately
COPY meetupwebapp/meetupwebapp/*.csproj .
RUN dotnet restore --use-current-runtime

COPY meetupwebapp/meetupwebapp/ .
RUN dotnet publish --output /source/ --configuration Release --no-restore
RUN sed -n 's:.*<AssemblyName>\(.*\)</AssemblyName>.*:\1:p' *.csproj > __assemblyname
RUN if [ ! -s __assemblyname ]; then filename=$(ls *.csproj); echo ${filename%.*} > __assemblyname; fi

# Stage 2
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /source
COPY --from=builder /source .

ENV PORT 5000
EXPOSE 5000

ENTRYPOINT dotnet $(cat /source/__assemblyname).dll --urls "http://*:5000"
