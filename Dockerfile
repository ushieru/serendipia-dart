FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/serendipia.dart -o bin/serendipia
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/serendipia /app/bin/
CMD ["/app/bin/serendipia"]
