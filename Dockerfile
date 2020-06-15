FROM alpine:latest 

RUN apk add nodejs npm git && \
    npm set optional false && \ 
    npm install -g pkg &&\
    cd ~/ && \
    git clone https://github.com/irab/ssb-server &&\
    cd ssb-server &&\
    npm install node-gyp &&\
    mkdir -p prebuilds/linux-x64/ &&\
    cp node_modules/leveldown/prebuilds/linux-x64/node.napi.musl.node prebuilds/linux-x64 && \
    pkg . --targets alpine
    
FROM alpine:latest  
RUN apk --no-cache add libstdc++
# WORKDIR /root/

COPY --from=0 /root/ssb-server/ssb-server .
COPY --from=0 /root/ssb-server/prebuilds/linux-x64/node.napi.musl.node ./prebuilds/linux-x64/

EXPOSE 8008

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=10 \
  CMD ssb-server whoami || exit 1
ENV HEALING_ACTION RESTART

ENTRYPOINT [ "./ssb-server" ]
CMD [ "start" ]