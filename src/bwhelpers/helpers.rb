#!/usr/bin/env ruby
#


class Helpers

    def make_hoa
        hoa = Hash.new do |k1,v1|
            k1[v1] = Array.new
        end
    end

    def make_hoh(x=0)
        hoh = Hash.new do |k1,v1|
            k1[v1] = Hash.new(x)
        end
    end

    def print_hoh(hoh)
        hoh.each do |k1,v1|
            v1.each do |k2,v2|
                puts "#{k1},#{k2},#{v2}"
            end
        end
    end

    def make_hohoa
        hohoa = Hash.new do |k1,v1|
            k1[v1] = Hash.new do |k2,v2|
                k2[v2] = Array.new
            end
        end
    end

    def make_hohoh(x=0)
        hohoh = Hash.new do |k1,v1|
            k1[v1] = Hash.new do |k2,v2|
                k2[v2] = Hash.new(x)
            end
        end
    end

    def make_hohohoa
        hohoh = Hash.new do |k1,v1|
            k1[v1] = Hash.new do |k2,v2|
                k2[v2] = Hash.new do |k3,v3|
                    k3[v3] = Array.new
                end
            end
        end
    end    

    def make_hohohoh(x=0)
        hohoh = Hash.new do |k1,v1|
            k1[v1] = Hash.new do |k2,v2|
                k2[v2] = Hash.new do |k3,v3|
                    k3[v3] = Hash.new(x)
                end
            end
        end
    end    
end
        

