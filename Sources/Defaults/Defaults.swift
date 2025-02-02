// MIT License © Sindre Sorhus
import Foundation

public protocol DefaultsBaseKey {
	var name: String { get }
	var suite: UserDefaults { get }
}

extension DefaultsBaseKey {
	/**
	Reset the item back to its default value.
	*/
	public func reset() {
		suite.removeObject(forKey: name)
	}
}

public enum Defaults {
	public typealias BaseKey = DefaultsBaseKey
	public typealias Keys = AnyKey
	public typealias Serializable = DefaultsSerializable
	public typealias CollectionSerializable = DefaultsCollectionSerializable
	public typealias SetAlgebraSerializable = DefaultsSetAlgebraSerializable
	public typealias PreferRawRepresentable = DefaultsPreferRawRepresentable
	public typealias PreferNSSecureCoding = DefaultsPreferNSSecureCoding
	public typealias Bridge = DefaultsBridge
	public typealias RangeSerializable = DefaultsRange & DefaultsSerializable
	typealias CodableBridge = DefaultsCodableBridge

	// We cannot use `Key` as the container for keys because of "Static stored properties not supported in generic types".
	public class AnyKey: BaseKey {
		public typealias Key = Defaults.Key

		public let name: String
		public let suite: UserDefaults

		fileprivate init(name: String, suite: UserDefaults) {
			self.name = name
			self.suite = suite
		}
	}

	public final class Key<Value: Serializable>: AnyKey {
		public let defaultValue: Value

		/**
		Create a defaults key.

		The `default` parameter can be left out if the `Value` type is an optional.
		*/
		public init(_ key: String, default defaultValue: Value, suite: UserDefaults = .standard) {
			self.defaultValue = defaultValue

			super.init(name: key, suite: suite)

			if (defaultValue as? _DefaultsOptionalProtocol)?.isNil == true {
				return
			}

			guard let serialized = Value.toSerializable(defaultValue) else {
				return
			}

			// Sets the default value in the actual UserDefaults, so it can be used in other contexts, like binding.
			suite.register(defaults: [name: serialized])
		}
	}

	public static subscript<Value: Serializable>(key: Key<Value>) -> Value {
		get { key.suite[key] }
		set {
			key.suite[key] = newValue
		}
	}
}

extension Defaults {
	/**
	Remove all entries from the given `UserDefaults` suite.

	- Note: This only removes user-defined entries. System-defined entries will remain.
	*/
	public static func removeAll(suite: UserDefaults = .standard) {
		suite.removeAll()
	}
}

extension Defaults.Key {
	public convenience init<T>(_ key: String, suite: UserDefaults = .standard) where Value == T? {
		self.init(key, default: nil, suite: suite)
	}
}

extension Defaults.AnyKey: Equatable {
	public static func == (lhs: Defaults.AnyKey, rhs: Defaults.AnyKey) -> Bool {
		lhs.name == rhs.name
			&& lhs.suite == rhs.suite
	}
}

extension Defaults.AnyKey: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(suite)
	}
}
