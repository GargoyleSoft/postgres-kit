extension PostgreSQLQuery {
    public struct ColumnConstraint {
        public static var notNull: ColumnConstraint {
            return .init(.notNull)
        }
        
        public static var null: ColumnConstraint {
            return .init(.null)
        }
        
        public static var primaryKey: ColumnConstraint {
            return .init(.primaryKey)
        }
        
        public static func generated(_ type: Constraint.Generated) -> ColumnConstraint {
            return .init(.generated(type))
        }
        
        public static func `default`(_ expr: Expression) -> ColumnConstraint {
            return .init(.default(expr))
        }
        
        public enum Constraint {
            case notNull
            case null
            case check(Key, noInherit: Bool)
            case `default`(Expression)
            public enum Generated {
                case always
                case byDefault
            }
            // FIXME: ("sequence options")
            case generated(Generated)
            case unique
            case primaryKey
            case references(Reference)
        }
        
        public struct Reference {
            public var foreignTable: String
            public var foreignColumn: String
            public var onDelete: ForeignKeyAction?
            public var onUpdate: ForeignKeyAction?
            
            public init(foreignTable: String, foreignColumn: String, onDelete: ForeignKeyAction? = nil, onUpdate: ForeignKeyAction? = nil) {
                self.foreignTable = foreignTable
                self.foreignColumn = foreignColumn
                self.onDelete = onDelete
                self.onUpdate = onUpdate
            }
        }
        
        public var name: String?
        public var constraint: Constraint
        public init(_ constraint: Constraint, name: String? = nil) {
            self.constraint = constraint
            self.name = name
        }
    }
}

extension PostgreSQLSerializer {
    internal func serialize(_ constraint: PostgreSQLQuery.ColumnConstraint) -> String {
        if let name = constraint.name {
            return "CONSTRAINT " + escapeString(name) + " " + serialize(constraint.constraint)
        } else {
            return serialize(constraint.constraint)
        }
    }
    
    internal func serialize(_ constraintType: PostgreSQLQuery.ColumnConstraint.Constraint) -> String {
        switch constraintType {
        case .null: return "NULL"
        case .notNull: return "NOT NULL"
        case .check(let expr, let noInherit):
            if noInherit {
                return serialize(expr) + " NO INHERIT"
            } else {
                return serialize(expr)
            }
        case .default(let expr): return "DEFAULT " + serialize(expr)
        case .generated(let generated):
            switch generated {
            case .always: return "GENERATED ALWAYS AS IDENTITY"
            case .byDefault: return "GENERATED BY DEFAULT AS IDENTITY"
            }
        case .unique: return "UNIQUE"
        case .primaryKey: return "PRIMARY KEY"
        case .references(let reference): return serialize(reference)
        }
    }
    internal func serialize(_ reference: PostgreSQLQuery.ColumnConstraint.Reference) -> String {
        var sql: [String] = []
        sql.append("REFERENCES")
        sql.append(escapeString(reference.foreignTable))
        sql.append(group([escapeString(reference.foreignColumn)]))
        if let onDelete = reference.onDelete {
            sql.append("ON DELETE")
            sql.append(serialize(onDelete))
        }
        if let onUpdate = reference.onUpdate {
            sql.append("ON UPDATE")
            sql.append(serialize(onUpdate))
        }
        return sql.joined(separator: " ")
    }
}
