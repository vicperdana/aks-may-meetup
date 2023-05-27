FROM mcr.microsoft.com/dotnet/aspnet:6.0 as base
ENV DOTNET_URLS=http://+:5000
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS builder
ARG TARGETARCH
ARG TARGETOS

RUN arch=$TARGETARCH \
    && if [ "$arch" = "arm64" ]; then arch="x64"; fi \
    && echo $TARGETOS-$arch > /tmp/rid

WORKDIR /source

# caches restore result by copying csproj file separately
COPY meetupwebapp/meetupwebapp/meetupwebapp.csproj .
RUN dotnet restore "meetupwebapp.csproj"
# build and publish app and libraries
COPY meetupwebapp/meetupwebapp .
WORKDIR /source/.
RUN dotnet build "meetupwebapp.csproj" -c Release -o /source/build --no-restore

FROM builder AS publish
RUN dotnet publish "meetupwebapp.csproj" --output /source/ --configuration Release --no-restore

FROM base AS final
RUN apt-get -y update; apt-get -y install curl
WORKDIR /source
COPY --from=publish /source .
ENV PORT 5000
EXPOSE 5000

ENTRYPOINT dotnet meetupwebapp.dll --urls "http://*:5000"