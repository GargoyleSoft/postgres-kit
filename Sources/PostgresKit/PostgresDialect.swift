public struct PostgresDialect: SQLDialect {
    public init() { }
    
    public var name: String {
        "postgresql"
    }

    public var identifierQuote: SQLExpression {
        return SQLRaw("\"")
    }

    public func bindPlaceholder(at position: Int) -> SQLExpression {
        return SQLRaw("$" + position.description)
    }

    public func literalBoolean(_ value: Bool) -> SQLExpression {
        switch value {
        case false:
            return SQLRaw("false")
        case true:
            return SQLRaw("true")
        }
    }

    public var autoIncrementClause: SQLExpression {
        return SQLRaw("GENERATED BY DEFAULT AS IDENTITY")
    }

    public var supportsAutoIncrement: Bool {
        true
    }

    public var enumSyntax: SQLEnumSyntax {
        .typeName
    }

    public var triggerSyntax: SQLTriggerSyntax {
        return .init(
            create: [.supportsForEach, .postgreSQLChecks, .supportsCondition, .conditionRequiresParentheses, .supportsConstraints],
            drop: [.supportsCascade, .supportsTableName]
        )
    }
}
