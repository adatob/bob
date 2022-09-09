package orm

type RelSide struct {
	From        string
	FromColumns []string
	To          string
	ToColumns   []string

	// If the destination columns contain the key
	// if false, it means the source columns are the foreign key
	ToKey bool
	// if the destination is unique
	ToUnique bool
	// If the key is nullable. We need this to know if we can remove the
	// relationship without deleting it
	KeyNullable bool
}

type Relationship struct {
	Name        string
	ByJoinTable bool
	Sides       []RelSide
}

func (r Relationship) Local() string {
	return r.Sides[0].From
}

func (r Relationship) Foreign() string {
	return r.Sides[len(r.Sides)-1].To
}

func (r Relationship) IsToMany() bool {
	for _, side := range r.Sides {
		if !side.ToUnique {
			return true
		}
	}

	return false
}

func (r Relationship) IsRemovable() bool {
	for _, side := range r.Sides {
		if side.KeyNullable {
			return true
		}
	}

	return false
}

type RelSetDetails struct {
	TableName string
	Mapped    []RelSetMapping
}

type RelSetMapping struct {
	Column         string
	ExternalTable  string
	ExternalColumn string
}

func (r Relationship) KeyedSides() []RelSetDetails {
	var x []RelSetDetails

	for i, side := range r.Sides {
		if !side.ToKey {
			if i != 0 && r.Sides[i-1].ToKey {
				continue
			}

			deets := RelSetDetails{
				TableName: side.From,
				Mapped:    make([]RelSetMapping, 0, len(side.FromColumns)),
			}
			for i, f := range side.FromColumns {
				deets.Mapped = append(deets.Mapped, RelSetMapping{
					Column:         f,
					ExternalTable:  side.To,
					ExternalColumn: side.ToColumns[i],
				})
			}

			x = append(x, deets)
			continue
		}

		deets := RelSetDetails{
			TableName: side.To,
			Mapped:    make([]RelSetMapping, 0, len(side.FromColumns)),
		}
		for i, f := range side.FromColumns {
			deets.Mapped = append(deets.Mapped, RelSetMapping{
				Column:         side.ToColumns[i],
				ExternalTable:  side.From,
				ExternalColumn: f,
			})
		}

		if len(r.Sides) > i+1 {
			nextSide := r.Sides[i+1]
			if !nextSide.ToKey {
				for i, f := range nextSide.FromColumns {
					deets.Mapped = append(deets.Mapped, RelSetMapping{
						Column:         f,
						ExternalTable:  nextSide.To,
						ExternalColumn: nextSide.ToColumns[i],
					})
				}
			}
		}

		x = append(x, deets)
	}

	return x
}
