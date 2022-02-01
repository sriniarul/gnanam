FROM pupilfirst:development

RUN chmod +x docker/entrypoints/rescript.sh

CMD ["yarn", "run", "re:watch"]
