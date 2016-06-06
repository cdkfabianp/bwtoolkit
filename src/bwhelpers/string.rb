class String

    def to_bool
        (self =~ /^true$/i) == 0
    end
end
