import dbConnect from '../../../lib/mongodb';
import Fontanella from '../../../models/Fontanella';

export default async function handler(req, res) {
  await dbConnect();

  const {
    query: { id },
    method,
  } = req;

  switch (method) {
    case 'GET':
      try {
        const fontanella = await Fontanella.findById(id).populate('createdBy');
        if (!fontanella) {
          return res.status(404).json({ error: 'Not found' });
        }

        let response = fontanella.toObject();

        if (response.createdBy && typeof response.createdBy === 'object') {
          response.createdBy = {
            id: response.createdBy._id,
            name: response.createdBy.name ?? '-',
          };
        } else if (typeof response.createdBy === 'string') {
          response.createdBy = {
            id: response.createdBy,
            name: '-',
          };
        }

        res.status(200).json(response);
      } catch (error) {
        console.error(error);
        res.status(400).json({ error: 'Invalid ID' });
      }
      break;
    case 'PUT':
      const { name, lat, lon } = req.body;

      if (
        !name || typeof name !== 'string' ||
        typeof lat !== 'number' ||
        typeof lon !== 'number'
      ) {
        return res.status(400).json({ error: 'Missing or invalid fields' });
      }

      try {
        const updated = await Fontanella.findByIdAndUpdate(
          id,
          { name, lat, lon },
          { new: true, runValidators: true }
        );
        if (!updated) return res.status(404).json({ error: 'Not found' });
        res.status(200).json(updated);
      } catch {
        res.status(400).json({ error: 'Update failed' });
      }
      break;

    case 'DELETE':
      try {
        const deleted = await Fontanella.findByIdAndDelete(id);
        if (!deleted) {
          return res.status(404).json({ error: 'Not found' });
        }
        res.status(200).json({ success: true });
      } catch (error) {
        res.status(400).json({ error: 'Delete failed' });
      }
      break;

    default:
      res.setHeader('Allow', ['GET', 'PUT', 'DELETE']);
      res.status(405).end(`Method ${method} Not Allowed`);
  }
}
