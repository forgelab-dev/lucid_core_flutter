/// Point d'indirection unique utilisé par tous les mixins de configuration
/// (`LucidAppConfigMixin`, `LucidNetworkConfigMixin`, ...) pour résoudre la
/// valeur d'une propriété.
///
/// Par défaut, une propriété résout simplement à sa valeur par défaut.
/// `LucidOverrideConfig` redéfinit [resolveConfig] pour donner la priorité à
/// un override explicite quand il existe, sans que chaque mixin ait besoin
/// de connaître l'existence des overrides.
abstract class LucidAbstractConfigResolver {
  T resolveConfig<T>(String key, T defaultValue) => defaultValue;
}
