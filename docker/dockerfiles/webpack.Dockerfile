FROM pupilfirst:development

RUN chmod +x docker/entrypoints/webpack.sh

EXPOSE 3035

CMD ["yarn", "run", "wds"]
