class AddTimerangeDatatype < ActiveRecord::Migration
  def change
  	execute <<-__EOI
  		do $$
			begin
  			IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'timerange') THEN
        	create type timerange as range (subtype = time);
      	END IF;
      end$$;
  	__EOI
  end
end
